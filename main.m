//
//  main.m
//  weather
//
//  Created by Сергей Голубев on 21.06.2018.
//  Copyright © 2018 Сергей Голубев. All rights reserved.
//

#import <Foundation/Foundation.h>

struct factWeather{
    int temp;
    int feel_temp;
    float wind;
    char *condition;
    int time;
};

struct factWeather getWeather(float lat, float lon){
    NSString *query = [[NSString alloc] initWithFormat:@"lat=%f&lon=%f",lat,lon];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    
    NSURLComponents *component = [[NSURLComponents alloc] init];
    component.scheme = @"https";
    component.host = @"api.weather.yandex.ru";
    component.path = @"/v1/informers";
    component.query = query;
    
    NSURL * url = [NSURL alloc];
    url = component.URL;
    [request setURL:url];
    [request setValue:@"9fe1f00d-841a-46d1-bc2e-70621ba8fe65" forHTTPHeaderField:@"X-Yandex-API-Key"];
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        exit(1) ;
    }
    id object = [NSJSONSerialization JSONObjectWithData:oResponseData options:0 error:&error];
    struct factWeather dataWeather;
    dataWeather.temp = [[object[@"fact"] valueForKey:@"temp"] intValue];
    dataWeather.feel_temp = [[object[@"fact"] valueForKey:@"feels_like"] intValue];
    dataWeather.condition = [[object[@"fact"] valueForKey:@"condition"] UTF8String];
    dataWeather.wind = [[object[@"fact"] valueForKey:@"wind_speed"] floatValue];
    dataWeather.time = [[object[@"fact"]valueForKey:@"obs_time"]  intValue];
    return dataWeather;
}
void drawInterface(char *cityName, float lat, float lon){
    struct factWeather dataWeather;

    printf("\t\t\t\t%s\n",cityName);
    dataWeather = getWeather(lat, lon);
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:dataWeather.time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"HH:mm dd-MM-yyyy"];
    
    printf("%s\n",[[formatter stringFromDate:date] UTF8String]);
   // printf("\t\t %f \t\t %f\n", lat,lon);
    printf("|%-10s|%-15s|%-25s|%-15s|\n","Temp.","Feels_temp.","Condition","Wind_Speed");

    
    printf("|%-10d|%-15d|%-25s|%-15.2f|\n\n",dataWeather.temp,
                dataWeather.feel_temp,
                dataWeather.condition,
                dataWeather.wind);
}
void getCoordCity(char* cityName){
    NSString *city = [[NSString alloc] initWithUTF8String:cityName];
    NSString *query = [[NSString alloc] initWithFormat:@"format=json&geocode=%@",city];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    
    NSURLComponents *component = [[NSURLComponents alloc] init];
    component.scheme = @"https";
    component.host = @"geocode-maps.yandex.ru";
    component.path = @"/1.x/";
    component.query = query;
    
    NSURL * url = [NSURL alloc];
    url = component.URL;
    [request setURL:url];
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        exit(1) ;
    }
    id object = [NSJSONSerialization JSONObjectWithData:oResponseData options:0 error:&error];
    NSDictionary * test = object[@"response"][@"GeoObjectCollection"][@"featureMember"];
    NSDictionary *test2 = [[test valueForKey:@"GeoObject"] valueForKey:@"Point"];
    NSArray *names = [[test valueForKey:@"GeoObject"] valueForKey:@"name"];
    NSArray *coords = [test2 valueForKey:@"pos"];
    
    for(id object in names){
        static int i = 0;
        if([object isKindOfClass:[NSString class]]){
            NSArray *floats = [coords[i] componentsSeparatedByString:@" "];
            i++;
            drawInterface([object UTF8String],[floats[0] floatValue],[floats[1] floatValue]);
        }
        
    }
}

int main(int argc,  char * argv[] ) {
    @autoreleasepool {
        char * cityName;
        
        if(argc == 1){
         cityName = malloc(strlen("Санкт-Петербург"));
        }
        else if(argc == 2){
            cityName = argv[1];
            cityName = malloc(strlen(argv[1]));
            int test = strlen(argv[1]);
            memcpy(cityName, argv[1], strlen(argv[1]));
        }
        else {
            NSLog(@"Error with command");
            return 0;
        }

        printf("==========================Погода============================\n\n");
        getCoordCity(cityName);
        
        

    }
    return 0;
}
