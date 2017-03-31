# Code4Good - Hackathon 2017
This repository is meant for the health case (stress prevention). It provides some basic code to get started with consuming the Muse and Lifetracker (heartrate) data. It utilizes an iOS app that connects to the devices via bluetooth (BLE) and sends this information to SCP using websockets. For prototyping purposes a lightweight java websocket proxy is provided as well. Which can be deployed to a SCP java compute unit and sends all data received from a websocket client to all other clients connected to the websocket proxy. 

Please use the code at your own risk and as mentioned it is very basic, so it is only to help you get started. 

Good luck


For HTTP Calls

```
- (void) sendDataOverHttp:(NSString*) jsonRequest{
        
            NSURL *url = [NSURL URLWithString:@"https://iotmms<account>.hanatrial.ondemand.com/com.sap.iotservices.mms/v1/api/http/data/<device id>"];
        
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        
            NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
        
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"Bearer <oath token>" forHTTPHeaderField:@"Authorization"];
            [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody: requestData];
    
//            if (!httpDataSending){
//                httpDataSending = true;

                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response,
                                                           NSData *data, NSError *connectionError)
                 {
                     if (data.length > 0 && connectionError == nil)
                     {
                         //NSLog(@"REST Call Server Response is %@", response);
//                         [NSTimer scheduledTimerWithTimeInterval:0.1
//                                                          target:self
//                                                        selector:@selector(setHttpDataSendFinishedAfterDelay:)
//                                                        userInfo:nil
//                                                         repeats:NO];
                     }else{
                         NSLog(@"REST Call Error is %@", connectionError.description);

                     }
                 }];
//                httpDataSending = true;
//        
//            }

}
```