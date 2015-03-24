//  ReportDownloader.m
//
//  Copyright (c) 2015 Clemens Schulz
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "CSReportsDownloader.h"

NSString * const CSReportsDownloaderErrorDomain = @"CSReportsDownloaderErrorDomain";

@interface CSReportsDownloader ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation CSReportsDownloader

- (NSString *)encodeString:(NSString *)string {
    // URL encode string
    // stringByAddingPercentEscapesUsingEncoding: does not escape every character
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

- (NSString *)stringForReportType:(CSReportType)reportType {
    if (reportType == CSReportTypeSales)
        return @"Sales";
    else if (reportType == CSReportTypeNewsstand)
        return @"Newsstand";
    else
        return nil;
}

- (NSString *)stringForReportSubtype:(CSReportSubtype)reportSubtype {
    if (reportSubtype == CSReportSubtypeSummary)
        return @"Summary";
    else if (reportSubtype == CSReportSubtypeDetailed)
        return @"Detailed";
    else if (reportSubtype == CSReportSubtypeOptIn)
        return @"Opt-In";
    else
        return nil;
}

- (NSString *)stringForDateType:(CSDateType)dateType {
    if (dateType == CSDateTypeDaily)
        return @"Daily";
    else if (dateType == CSDateTypeWeekly)
        return @"Weekly";
    else if (dateType == CSDateTypeMonthly)
        return @"Monthly";
    else if (dateType == CSDateTypeYearly)
        return @"Yearly";
    else
        return nil;
}

- (NSURLSessionDownloadTask *)downloadReportForDate:(NSDate *)date completionHandler:(void (^)(NSURL *location, NSString *suggestedFilename, NSError *error))completionHandler {
    NSParameterAssert(completionHandler != nil);
    
    NSString *urlString = @"https://reportingitc.apple.com/autoingestion.tft?";
    
    urlString = [urlString stringByAppendingFormat:@"USERNAME=%@", [self encodeString:self.userID]];
    urlString = [urlString stringByAppendingFormat:@"&PASSWORD=%@", [self encodeString:self.password]];
    urlString = [urlString stringByAppendingFormat:@"&VNDNUMBER=%@", [self encodeString:self.vendorID]];
    
    NSString *reportType = [self stringForReportType:self.reportType];
    urlString = [urlString stringByAppendingFormat:@"&TYPEOFREPORT=%@", [self encodeString:reportType]];
    
    NSString *dateType = [self stringForDateType:self.dateType];
    urlString = [urlString stringByAppendingFormat:@"&DATETYPE=%@", [self encodeString:dateType]];
    
    NSString *reportSubtype = [self stringForReportSubtype:self.reportSubtype];
    urlString = [urlString stringByAppendingFormat:@"&REPORTTYPE=%@", [self encodeString:reportSubtype]];
    
    if (date == nil) {
        // Set date to yesterday
        date = [NSDate dateWithTimeIntervalSinceNow:-86400.0];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (self.dateType == CSDateTypeDaily || self.dateType == CSDateTypeWeekly)
        formatter.dateFormat = @"yyyyMMdd";
    else if (self.dateType == CSDateTypeMonthly)
        formatter.dateFormat = @"yyyyMM";
    else
        formatter.dateFormat = @"yyyy";
    
    NSString *reportDate = [formatter stringFromDate:date];
    urlString = [urlString stringByAppendingFormat:@"&REPORTDATE=%@", [self encodeString:reportDate]];
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    if (self.session == nil) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        self.session = session;
    }
    
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error != nil || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            completionHandler(nil, nil, error);
        }
        
        NSDictionary *allHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
        NSString *errorMessage = allHeaderFields[@"ERRORMSG"];
        if (errorMessage != nil) {
            error = [NSError errorWithDomain:CSReportsDownloaderErrorDomain
                                        code:0
                                    userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            completionHandler(nil, nil, error);
        } else {
            completionHandler(location, response.suggestedFilename, nil);
        }
    }];
    [downloadTask resume];
    
    return downloadTask;
}

@end
