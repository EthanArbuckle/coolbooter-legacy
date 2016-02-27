//
//  CBImagePatcher.m
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/26/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "CBImagePatcher.h"

@implementation CBImagePatcher

static int64_t offtin(uint8_t *buf)
{
    int64_t y;
    
    y=buf[7]&0x7F;
    y=y*256;y+=buf[6];
    y=y*256;y+=buf[5];
    y=y*256;y+=buf[4];
    y=y*256;y+=buf[3];
    y=y*256;y+=buf[2];
    y=y*256;y+=buf[1];
    y=y*256;y+=buf[0];
    
    if(buf[7]&0x80) y=-y;
    
    return y;
}


+ (void)applyPatchAtURL:(NSString *)stringURL toFile:(NSString *)file saveLocation:(NSString *)saveLocation {
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:stringURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
            NSLog(@"failed downloading patch %@", stringURL);
            return;
        }
        
        [data writeToFile:[NSString stringWithFormat:@"%@.patch", file] atomically:YES];
        
        
        /*-
         * Copyright 2003-2005 Colin Percival
         * Copyright 2012 Matthew Endsley
         * All rights reserved
         *
         * Redistribution and use in source and binary forms, with or without
         * modification, are permitted providing that the following conditions
         * are met:
         * 1. Redistributions of source code must retain the above copyright
         *    notice, this list of conditions and the following disclaimer.
         * 2. Redistributions in binary form must reproduce the above copyright
         *    notice, this list of conditions and the following disclaimer in the
         *    documentation and/or other materials provided with the distribution.
         *
         * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
         * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
         * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
         * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
         * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
         * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
         * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
         * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
         * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
         * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
         * POSSIBILITY OF SUCH DAMAGE.
         */
        
        FILE * f, * cpf, * dpf, * epf;
        BZFILE * cpfbz2, * dpfbz2, * epfbz2;
        int cbz2err, dbz2err, ebz2err;
        int fd;
        ssize_t oldsize,newsize;
        ssize_t bzctrllen,bzdatalen;
        u_char header[32],buf[8];
        u_char *old, *new;
        off_t oldpos,newpos;
        off_t ctrl[3];
        off_t lenread;
        off_t i;
        
        if ((f = fopen([[NSString stringWithFormat:@"%@.patch", file] UTF8String], "r")) == NULL) {
            NSLog(@"failed to open file");
        }
        
        if (fread(header, 1, 32, f) < 32) {
            NSLog(@"corrupt patch");
        }
        
        if (memcmp(header, "BSDIFF40", 8) != 0) {
            NSLog(@"not a patch");
        }
        
        /* Read lengths from header */
        bzctrllen=offtin(header+8);
        bzdatalen=offtin(header+16);
        newsize=offtin(header+24);
        if((bzctrllen<0) || (bzdatalen<0) || (newsize<0)) {
            NSLog(@"corrupt patch");
        }
        
        fclose(f);
        cpf = fopen([[NSString stringWithFormat:@"%@.patch", file] UTF8String], "r");
        fseeko(cpf, 32, SEEK_SET);
        cpfbz2 = BZ2_bzReadOpen(&cbz2err, cpf, 0, 0, NULL, 0);
        dpf = fopen([[NSString stringWithFormat:@"%@.patch", file] UTF8String], "r");
        fseeko(dpf, 32 + bzctrllen, SEEK_SET);
        dpfbz2 = BZ2_bzReadOpen(&dbz2err, dpf, 0, 0, NULL, 0);
        epf = fopen([[NSString stringWithFormat:@"%@.patch", file] UTF8String], "r");
        fseeko(epf, 32 + bzctrllen + bzdatalen, SEEK_SET);
        epfbz2 = BZ2_bzReadOpen(&ebz2err, epf, 0, 0, NULL, 0);
        
        if(((fd=open([file UTF8String],O_RDONLY,0))<0) || ((oldsize=lseek(fd,0,SEEK_END))==-1) || ((old=malloc(oldsize+1))==NULL) || (lseek(fd,0,SEEK_SET)!=0) || (read(fd,old,oldsize)!=oldsize) || (close(fd)==-1)) {
            NSLog(@"fail.");
        }
        if((new=malloc(newsize+1))==NULL) {
            NSLog(@"malloc failed");
        }
        
        oldpos=0;newpos=0;
        while(newpos<newsize) {
            /* Read control data */
            for(i=0;i<=2;i++) {
                lenread = BZ2_bzRead(&cbz2err, cpfbz2, buf, 8);
                if ((lenread < 8) || ((cbz2err != BZ_OK) &&
                                      (cbz2err != BZ_STREAM_END)))
                    NSLog(@"corrupt");
                ctrl[i]=offtin(buf);
            };
            
            /* Sanity-check */
            if(newpos+ctrl[0]>newsize)
                NSLog(@"corrupt patch");
            
            /* Read diff string */
            lenread = BZ2_bzRead(&dbz2err, dpfbz2, new + newpos, ctrl[0]);
            if ((lenread < ctrl[0]) ||
                ((dbz2err != BZ_OK) && (dbz2err != BZ_STREAM_END)))
               NSLog(@"corrupt patch");
            
            /* Add old data to diff string */
            for(i=0;i<ctrl[0];i++)
                if((oldpos+i>=0) && (oldpos+i<oldsize))
                    new[newpos+i]+=old[oldpos+i];
            
            /* Adjust pointers */
            newpos+=ctrl[0];
            oldpos+=ctrl[0];
            
            /* Sanity-check */
            if(newpos+ctrl[1]>newsize)
                NSLog(@"corrupt patch");
            
            /* Read extra string */
            lenread = BZ2_bzRead(&ebz2err, epfbz2, new + newpos, ctrl[1]);
            if ((lenread < ctrl[1]) ||
                ((ebz2err != BZ_OK) && (ebz2err != BZ_STREAM_END)))
                NSLog(@"corrupt patch");
            
            /* Adjust pointers */
            newpos+=ctrl[1];
            oldpos+=ctrl[2];
        };
        
        /* Clean up the bzip2 reads */
        BZ2_bzReadClose(&cbz2err, cpfbz2);
        BZ2_bzReadClose(&dbz2err, dpfbz2);
        BZ2_bzReadClose(&ebz2err, epfbz2);
        if (fclose(cpf) || fclose(dpf) || fclose(epf))
            NSLog(@"closing error?");
        
        /* Write the new file */
        if(((fd=open([saveLocation UTF8String],O_CREAT|O_TRUNC|O_WRONLY,0666))<0) ||
           (write(fd,new,newsize)!=newsize) || (close(fd)==-1))
            NSLog(@"write error");
        
        free(new);
        free(old);

        
    }] resume];
}

@end
