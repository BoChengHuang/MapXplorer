//
//  Server.m
//
//  Licensed under the Apache 2.0 license
//  http://apache.org/licenses/LICENSE-2.0
//
//  Created by Bill Dudney on 2/20/09.
//  Copyright 2009 Gala Factory Software LLC. All rights reserved.
//

#import "Server.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

NSString * const ServerErrorDomain = @"ServerErrorDomain";

static void SocketAcceptedConnectionCallBack(CFSocketRef socket,                // The call back function called when the server accepts a connection
                                             CFSocketCallBackType type, 
                                             CFDataRef address, 
                                             const void *data, void *info);

@interface Server()
    @property(nonatomic, copy) NSString *domain;
    @property(nonatomic, copy) NSString *protocol;
    @property(nonatomic, copy) NSString *name;
    @property(nonatomic, retain) NSNetService *netService;
    @property(assign) uint16_t port;

    @property(nonatomic, retain) NSInputStream *inputStream;
    @property(nonatomic, retain) NSOutputStream *outputStream;
    @property(nonatomic, assign) BOOL inputStreamReady;
    @property(nonatomic, assign) BOOL outputStreamReady;
    @property(nonatomic, assign) BOOL outputStreamHasSpace;

    @property(nonatomic, retain) NSNetServiceBrowser *browser;
    @property(nonatomic, retain) NSNetService *localService;
    @property(nonatomic, retain) NSNetService *currentlyResolvingService;
@end

@interface Server(Private)
    - (void)_streamCompletedOpening:(NSStream *)stream;
    - (void)_streamHasBytes:(NSStream *)stream;
    - (void)_streamHasSpace:(NSStream *)stream;
    - (void)_streamEncounteredEnd:(NSStream *)stream;
    - (void)_streamEncounteredError:(NSStream *)stream;
    - (void)_remoteServiceResolved:(NSNetService *)remoteService;
    - (void)_connectedToInputStream:(NSInputStream *)inputStream
                       outputStream:(NSOutputStream *)outputStream;
    - (void)_searchForServicesOfType:(NSString *)type;
    - (BOOL)_publishNetService;
    - (void)_stopStreams;
    - (void)_stopNetService;
@end


@implementation Server

@synthesize domain = _domain;
@synthesize protocol = _protocol;
@synthesize name = _name;
@synthesize delegate = _delegate;
@synthesize port = _port;
@synthesize netService = _netService;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize inputStreamReady = _inputStreamReady;
@synthesize outputStreamReady = _outputStreamReady;
@synthesize outputStreamHasSpace = _outputStreamHasSpace;
@synthesize payloadSize = _payloadSize;
@synthesize browser = _browser;
@synthesize localService = _localService;
@synthesize currentlyResolvingService = _currentlyResolvingService;

// Uses default protocol named 'Server' and TCP
- (id)init {
    self = [super init];
    if(nil == self) {
        self = [self initWithDomainName:@""
                               protocol:@"_Server._tcp."
                                   name:@""];
    }
    return self;
}

// Uses 'protocol' as the bonjour protocol and TCP as the networking layer
- (id)initWithProtocol:(NSString *)protocol {
    self = [super init];
    if(nil != self) {
        self = [self initWithDomainName:@""
                               protocol:[NSString stringWithFormat:@"_%@._tcp.", protocol]
                                   name:@""];
    }
    return self;
}

// Uses 'protocol' as the bonjour protocol publishes under domain
// With 'name' as its bonjour name, remember that name is advisory
// Make sure that after you start that you get the servers name
// Property to ensure that you have it correct
- (id)initWithDomainName:(NSString *)domain
                protocol:(NSString *)protocol
                    name:(NSString *)name {
    self = [super init];
    if(nil != self) {
        self.domain = domain;
        self.protocol = protocol;
        self.name = name;
        self.outputStreamHasSpace = NO;
        self.payloadSize = 128;
    }
    return self;
}

// Start the server, returns YES if successful and NO if not
// If NO is returned there will be more detail in the error object
// If you don't care about the error you can pass NULL
- (BOOL)start:(NSError **)error {
    BOOL successful = YES;
    CFSocketContext socketCtxt = {0, (__bridge void *)(self), NULL, NULL, NULL};
    _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, 
                             IPPROTO_TCP, 
                             kCFSocketAcceptCallBack,
                             (CFSocketCallBack)&SocketAcceptedConnectionCallBack,
                             &socketCtxt);
	
    if (NULL == _socket) {
        if (nil != error) {
            *error = [[NSError alloc] 
                      initWithDomain:ServerErrorDomain
                      code:kServerNoSocketsAvailable
                      userInfo:nil];
        }
        successful = NO;
    }
	
    if(YES == successful) {
        int yes = 1;                                            // Enable address reuse
        setsockopt(CFSocketGetNative(_socket), 
                   SOL_SOCKET, SO_REUSEADDR,
                   (void *)&yes, sizeof(yes));
        uint8_t packetSize = self.payloadSize;                  // Set the packet size for send and receive
        setsockopt(CFSocketGetNative(_socket),                  // cuts down on latency and such when sending
                   SOL_SOCKET, SO_SNDBUF,                       // small packets
                   (void *)&packetSize, sizeof(packetSize));
        setsockopt(CFSocketGetNative(_socket),
                   SOL_SOCKET, SO_RCVBUF,
                   (void *)&packetSize, sizeof(packetSize));
        struct sockaddr_in addr4;                               // Set up the IPv4 endpoint; use port 0, so the kernel 
        memset(&addr4, 0, sizeof(addr4));                       // will choose an arbitrary port for us, which will be 
        addr4.sin_len = sizeof(addr4);                          // advertised through Bonjour
        addr4.sin_family = AF_INET;
        addr4.sin_port = 0;                                     // Since we set it to zero the kernel will assign one for us
        addr4.sin_addr.s_addr = htonl(INADDR_ANY);
        NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
        
        if (kCFSocketSuccess != CFSocketSetAddress(_socket, (__bridge CFDataRef)address4)) {
            if (error) *error = [[NSError alloc] 
                                 initWithDomain:ServerErrorDomain
                                 code:kServerCouldNotBindToIPv4Address
                                 userInfo:nil];
            if (_socket) CFRelease(_socket);
            _socket = NULL;
            successful = NO;
        } else {
            NSData *addr = (__bridge NSData *)CFSocketCopyAddress(_socket);     // Now that the binding was successful, we get the port number
            memcpy(&addr4, [addr bytes], [addr length]);
            self.port = ntohs(addr4.sin_port);
            
            CFRunLoopRef cfrl = CFRunLoopGetCurrent();                          // Set up the run loop sources for the sockets
            CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
            CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
            CFRelease(source4);
            
            if(![self _publishNetService]) {
                successful = NO;
            }
        }
	}

    return successful;
}

// Send data to the remote side of the server
// On success returns YES, other wise returns NO
// If NO is returned more detail will be in the error
// If you don't care about the error you can pass NULL
- (BOOL)sendData:(NSData *)data error:(NSError **)error {
    BOOL successful = NO;
    if(self.outputStreamHasSpace) {
        // Push the whole gob of data onto the output stream
        // TODO: check to see if data is longer than the payloadSize
        // and break it up if so
        NSInteger len = [self.outputStream write:[data bytes] maxLength:[data length]];
        if(-1 == len) {
            // Error occured
            *error = [[NSError alloc] 
                      initWithDomain:ServerErrorDomain
                      code:kServerNoSpaceOnOutputStream
                      userInfo:[[self.outputStream streamError] userInfo]];
        } else if(0 == len) {
            // Stream has reached capacity
            *error = [[NSError alloc] 
                      initWithDomain:ServerErrorDomain
                      code:kServerOutputStreamReachedCapacity
                      userInfo:[[self.outputStream streamError] userInfo]];
        } else {
            successful = YES;
        }
    } else {
        *error = [[NSError alloc] initWithDomain:ServerErrorDomain
                                            code:kServerNoSpaceOnOutputStream
                                        userInfo:nil];
    }
    return successful;
}

// Call this when the user has selected the remote service they want to connect to
// should be one of the services sent to the delegate method
// serviceAdded:moreComing: method
- (void)connectToRemoteService:(NSNetService *)selectedService {
    [self.currentlyResolvingService stop];
    self.currentlyResolvingService = nil;
    
    self.currentlyResolvingService = selectedService;
    self.currentlyResolvingService.delegate = self;
    [self.currentlyResolvingService resolveWithTimeout:0.0];
}

// Stop the server
// turns off the netService
// closes the socket
// stops the streams
// tells the delegate that the server has stoped
- (void)stop {
    if(nil != self.netService) {
        [self _stopNetService];
    }
    if(NULL != _socket) {
        CFSocketInvalidate(_socket);
        CFRelease(_socket);
        _socket = NULL;
    }
    [self _stopStreams];
    [self.delegate serverStopped:self];
}

// Turns of browsing for like protocol bonjour services
- (void)stopBrowser {
    [self.browser stop];
    self.browser = nil;
    [self.localService stop];
    self.localService = nil;
    [self.currentlyResolvingService stop];
    self.currentlyResolvingService = nil;
}

- (void)dealloc {
    [self stop];
    [self stopBrowser];
    self.domain = nil;
    self.protocol = nil;
    self.name = nil;
    _delegate = nil;
}

#pragma mark NSNetServiceDelegate methods

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    [self.currentlyResolvingService stop];
    self.currentlyResolvingService = nil;
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
	assert(service == self.currentlyResolvingService);
    
    [self.currentlyResolvingService stop];
    self.currentlyResolvingService = nil;
	
    [self _remoteServiceResolved:service];
}

- (void)netServiceDidPublish:(NSNetService *)service {
    self.localService = service;
    self.name = service.name;
	[self _searchForServicesOfType:self.protocol];      // Now start looking for others
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorInfo {
    [self.delegate server:self didNotStart:errorInfo];
}

#pragma mark -

#pragma mark NetServiceBrowser setup and delegate methods

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser
         didRemoveService:(NSNetService*)service
               moreComing:(BOOL)moreComing {
    NSLog(@"Current Resolving Service Name: %@", self.currentlyResolvingService.name);
    NSLog(@"Local Service Name: %@", self.localService.name);
    NSLog(@"Removed Service Name: %@", service.name);
    if([service.name isEqualToString:self.currentlyResolvingService.name]) {
        [self.currentlyResolvingService stop];
        self.currentlyResolvingService = nil;
    } else if([self.localService.name isEqualToString:service.name]) {
        self.localService = nil;
    }
    [self.delegate serviceRemoved:service moreComing:moreComing];
}	

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser
           didFindService:(NSNetService*)service
               moreComing:(BOOL)moreComing {
    NSLog(@"Local Service Name: %@", self.localService.name);
    NSLog(@"Found Service Name: %@", service.name);
	if(![service.name isEqual:self.localService.name]) {
        [self.delegate serviceAdded:service moreComing:moreComing];
    }
}

#pragma mark -

#pragma mark NSStreamDelegate methods

- (void) stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
      case NSStreamEventOpenCompleted: {
          [self _streamCompletedOpening:stream];
          break;
      }
      case NSStreamEventHasBytesAvailable: {
          [self _streamHasBytes:stream];
          break;
      }
      case NSStreamEventHasSpaceAvailable: {
          [self _streamHasSpace:stream];
          break;
      }
      case NSStreamEventEndEncountered: {
          [self _streamEncounteredEnd:stream];
          break;
      }
      case NSStreamEventErrorOccurred: {
          [self _streamEncounteredError:stream];
          break;
      }
      default:
          break;
    }
}

#pragma mark -

@end

@implementation Server(Private)

- (void)_streamCompletedOpening:(NSStream *)stream {
    if(stream == self.inputStream) {
        self.inputStreamReady = YES;
    }
    if(stream == self.outputStream) {
        self.outputStreamReady = YES;
    }
    
    if(YES == self.inputStreamReady && YES == self.outputStreamReady) {
        [self.delegate serverRemoteConnectionComplete:self];
        [self _stopNetService];
    }
}

- (void)_streamHasBytes:(NSStream *)stream {
    NSMutableData *data = [NSMutableData data];
    uint8_t *buf = calloc(self.payloadSize, sizeof(uint8_t));
    NSUInteger len = 0;
    while([(NSInputStream*)stream hasBytesAvailable]) {
        len = [self.inputStream read:buf maxLength:self.payloadSize];
        if(len > 0) {
            [data appendBytes:buf length:len];
        }
    }
    free(buf);
    [self.delegate server:self didAcceptData:data];
}

- (void)_streamHasSpace:(NSStream *)stream {
    self.outputStreamHasSpace = YES;
}

- (void)_streamEncounteredEnd:(NSStream *)stream {
    // Remote side died, tell the delegate then restart my local
    // service looking for some other server to connect to
    [self.delegate server:self lostConnection:nil];
    [self _stopStreams];
    [self _publishNetService];
}

- (void)_streamEncounteredError:(NSStream *)stream {
    [self.delegate server:self lostConnection:[[stream streamError] userInfo]];
    [self stop];
}

- (void)_remoteServiceResolved:(NSNetService *)remoteService {
    NSInputStream *inputStream = nil;
    NSOutputStream *outputStream = nil;
    
	if([remoteService getInputStream:&inputStream outputStream:&outputStream]) {
        [self _connectedToInputStream:inputStream outputStream:outputStream];
    }
    
    inputStream = nil;
    outputStream = nil;
}

- (void)_connectedToInputStream:(NSInputStream *)inputStream
                  outputStream:(NSOutputStream *)outputStream {
    // Need to close existing streams
    [self _stopStreams];
    
    self.inputStream = inputStream;
    self.inputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    
    self.outputStream = outputStream;
    self.outputStream.delegate = self;
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                 forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
}

- (void)_searchForServicesOfType:(NSString *)type {
	[self.browser stop];
    self.browser = nil;

	self.browser = [[NSNetServiceBrowser alloc] init];
	self.browser.delegate = self;
	[self.browser searchForServicesOfType:type inDomain:@"local"];
}

- (BOOL)_publishNetService {
    BOOL successful = NO;
    self.netService = [[NSNetService alloc] initWithDomain:self.domain
                                                       type:self.protocol
                                                       name:self.name
                                                       port:self.port];
    if(self.netService != nil) {
        [self.netService scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                   forMode:NSRunLoopCommonModes];
        [self.netService publish];
        self.netService.delegate = self;
        successful = YES;
    }
    return successful;
}

- (void)_stopStreams {
    if(nil != self.inputStream) {
        [self.inputStream close];
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                    forMode:NSRunLoopCommonModes];
        self.inputStream = nil;
        self.inputStreamReady = NO;
    }
    if(nil != self.outputStream) {
        [self.outputStream close];
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                     forMode:NSRunLoopCommonModes];
        self.outputStream = nil;
        self.outputStreamReady = NO;
    }
}

- (void)_stopNetService {
    [self.netService stop];
    [self.netService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.netService = nil;
}    

@end

static void SocketAcceptedConnectionCallBack(CFSocketRef socket, 
                                             CFSocketCallBackType type, 
                                             CFDataRef address, 
                                             const void *data, void *info) {
    // The server's socket has accepted a connection request
    // this function is called because it was registered in the
    // socket create method
    if (kCFSocketAcceptCallBack == type) { 
        Server *server = (__bridge Server *)info;
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;    // On an accept the data is the native socket handle
        CFReadStreamRef readStream = NULL;                                          // Create the read and write streams for the connection to the other process
		CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle,
                                     &readStream, &writeStream);
        if(NULL != readStream && NULL != writeStream) {
            CFReadStreamSetProperty(readStream, 
                                    kCFStreamPropertyShouldCloseNativeSocket,
                                    kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream, 
                                     kCFStreamPropertyShouldCloseNativeSocket,
                                     kCFBooleanTrue);
            [server _connectedToInputStream:(__bridge NSInputStream *)readStream
                               outputStream:(__bridge NSOutputStream *)writeStream];
        } else {
            // On any failure, need to destroy the CFSocketNativeHandle 
            // since we are not going to use it any more
            close(nativeSocketHandle);
        }
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
}
