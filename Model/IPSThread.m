/*
 Copyright (c) 2021, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "IPSThread.h"

#import "NSArray+WBExtensions.h"

NSString * const IPSThreadIDKey=@"id";

NSString * const IPSThreadQueueKey=@"queue";

NSString * const IPSThreadFramesKey=@"frames";

NSString * const IPSThreadTriggeredKey=@"triggered";

NSString * const IPSThreadThreadStateKey=@"threadState";

NSString * const IPSThreadInstructionStateKey=@"instructionState";

@interface IPSThread ()

    @property (readwrite,copy) NSString * queue;     // can be nil

    @property (readwrite) NSUInteger ID;

    @property (readwrite) NSArray<IPSThreadFrame *> * frames;

    @property (readwrite) BOOL triggered;

    @property (readwrite) IPSThreadState * threadState;  // can be nil

    @property (readwrite) IPSThreadInstructionState * instructionState;  // can be nil

@end

@implementation IPSThread

- (instancetype)initWithRepresentation:(NSDictionary *)inRepresentation error:(out NSError **)outError
{
    if (inRepresentation==nil)
    {
        if (outError!=NULL)
            *outError=[NSError errorWithDomain:IPSErrorDomain code:IPSRepresentationNilRepresentationError userInfo:nil];
        
        return nil;
    }
    
    if ([inRepresentation isKindOfClass:[NSDictionary class]]==NO)
    {
        if (outError!=NULL)
            *outError=[NSError errorWithDomain:IPSErrorDomain code:IPSRepresentationInvalidTypeOfValueError userInfo:nil];
        
        return nil;
    }
    
    self=[super init];
    
    if (self!=nil)
    {
        NSNumber * tNumber=inRepresentation[IPSThreadIDKey];
        
        if (tNumber!=nil)
        {
            IPSClassCheckNumberValueForKey(tNumber,IPSThreadIDKey);
        
            _ID=[tNumber unsignedIntegerValue];
        }
        
        NSString * tString=inRepresentation[IPSThreadQueueKey];
        
        if (tString!=nil)
        {
            IPSClassCheckStringValueForKey(tString,IPSThreadQueueKey);
            
            _queue=[tString copy];
        }
        
        NSArray * tArray=inRepresentation[IPSThreadFramesKey];
        
        if (tArray!=nil)
        {
            if ([tArray isKindOfClass:[NSArray class]]==NO)
            {
                if (outError!=NULL)
                    *outError=[NSError errorWithDomain:IPSErrorDomain
                                                  code:IPSRepresentationInvalidTypeOfValueError
                                              userInfo:@{IPSKeyPathErrorKey:(IPSThreadFramesKey)}];
                
                return nil;
            }
            
            _frames=[tArray WB_arrayByMappingObjectsUsingBlock:^IPSThreadFrame *(NSDictionary * bBThreadFrameRepresentation, NSUInteger bIndex) {
                
                IPSThreadFrame * tThreadFrame=[[IPSThreadFrame alloc] initWithRepresentation:bBThreadFrameRepresentation error:NULL];
                
                return tThreadFrame;
            }];
        }
    
        tNumber=inRepresentation[IPSThreadTriggeredKey];
        
        if (tNumber!=nil)
        {
            IPSClassCheckNumberValueForKey(tNumber,IPSThreadTriggeredKey);
        
            _triggered=[tNumber boolValue];
        }
        
        NSDictionary * tDictionary=inRepresentation[IPSThreadThreadStateKey];
        
        if (tDictionary!=nil)
        {
            _threadState=[[IPSThreadState alloc] initWithRepresentation:tDictionary error:outError];
        }
        
        tDictionary=inRepresentation[IPSThreadInstructionStateKey];
        
        if (tDictionary!=nil)
        {
            _instructionState=[[IPSThreadInstructionState alloc] initWithRepresentation:tDictionary error:outError];
        }
    }
    
    return self;
}

#pragma mark -

- (NSDictionary *)representation
{
    NSMutableDictionary * tMutableDictionary=[NSMutableDictionary dictionary];
    
    tMutableDictionary[IPSThreadIDKey]=@(self.ID);
    
    if (self.queue!=nil)
        tMutableDictionary[IPSThreadQueueKey]=self.queue;
    
    if (self.frames.count>0)
    {
        tMutableDictionary[IPSThreadFramesKey]=[self.frames WB_arrayByMappingObjectsUsingBlock:^NSDictionary *(IPSThreadFrame * bFrame, NSUInteger bIndex) {
            
            return [bFrame representation];
        }];
    }
    
    if (self.triggered==YES)
        tMutableDictionary[IPSThreadTriggeredKey]=@(YES);
    
    if (self.threadState!=nil)
        tMutableDictionary[IPSThreadThreadStateKey]=[self.threadState representation];
    
    return @{};
}

@end
