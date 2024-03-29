#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "img3.h"
#include "libxpwn.h"


void writeImg3Element(AbstractFile* file, Img3Element* element, Img3Info* info);

void writeImg3Root(AbstractFile* file, Img3Element* element, Img3Info* info);

void flipAppleImg3Header(AppleImg3Header* header) {
	FLIPENDIANLE(header->magic);
	FLIPENDIANLE(header->size);
	FLIPENDIANLE(header->dataSize);
}

void flipAppleImg3RootExtra(AppleImg3RootExtra* extra) {
	FLIPENDIANLE(extra->shshOffset);
	FLIPENDIANLE(extra->name);
}

void flipAppleImg3KBAGHeader(AppleImg3KBAGHeader* data) {
	FLIPENDIANLE(data->key_modifier);
	FLIPENDIANLE(data->key_bits);
}

size_t readImg3(AbstractFile* file, void* data, size_t len) {
	Img3Info* info = (Img3Info*) file->data;
	memcpy(data, (void*)((uint8_t*)info->data->data + (uint32_t)info->offset), len);
	info->offset += (size_t)len;
	return len;
}

size_t writeImg3(AbstractFile* file, const void* data, size_t len) {
	Img3Info* info = (Img3Info*) file->data;

	while((info->offset + (size_t)len) > info->data->header->dataSize) {
		uint32_t oldSize = info->data->header->dataSize;
		info->data->header->dataSize = info->offset + (size_t)len;
		info->data->header->size = info->data->header->dataSize;
		if(info->data->header->size % 0x20 != 0) {
			info->data->header->size += 0x20 - (info->data->header->size % 0x20); /* PwnageTool(mac): 0x20, Apple: 0x10? */
		}
		info->data->header->size += sizeof(AppleImg3Header);
		info->data->data = realloc(info->data->data, info->data->header->dataSize + 32); /* hack for decryptLast rounding up */
		memset((uint8_t *)info->data->data + oldSize, 0, info->data->header->dataSize + 32 - oldSize); /* bigger block, zero */
	}
	
	memcpy((void*)((uint8_t*)info->data->data + (uint32_t)info->offset), data, len);
	info->offset += (size_t)len;
	
	info->dirty = TRUE;
	
	return len;
}

int seekImg3(AbstractFile* file, off_t offset) {
	Img3Info* info = (Img3Info*) file->data;
	info->offset = (size_t)offset;
	return 0;
}

off_t tellImg3(AbstractFile* file) {
	Img3Info* info = (Img3Info*) file->data;
	return (off_t)info->offset;
}

off_t getLengthImg3(AbstractFile* file) {
	Img3Info* info = (Img3Info*) file->data;
	return info->data->header->dataSize;
}

void closeImg3(AbstractFile* file) {
	Img3Info* info = (Img3Info*) file->data;

	if(info->dirty) {
		if(info->encrypted) {
			uint32_t sz = info->data->header->dataSize;
			if (info->decryptLast) {
				sz = info->data->header->size;
			}
			uint8_t ivec[16];
			memcpy(ivec, info->iv, 16);
			AES_cbc_encrypt(info->data->data, info->data->data, (sz / 16) * 16, &(info->encryptKey), ivec, AES_ENCRYPT);
		}

		info->file->seek(info->file, 0);
		info->root->header->dataSize = 0;	/* hack to make certain writeImg3Element doesn't preallocate */
		info->root->header->size = 0;
		writeImg3Element(info->file, info->root, info);
	}

	info->root->free(info->root);
	info->file->close(info->file);
	free(info);
	free(file);
}

void setKeyImg3(AbstractFile2* file, const unsigned int* key, const unsigned int* iv) {
	Img3Info* info = (Img3Info*) file->super.data;
	if (!info->kbag) {
		return;
	}

	int i;
	uint8_t bKey[32];
	int keyBits = ((AppleImg3KBAGHeader*)info->kbag->data)->key_bits;

	for(i = 0; i < 16; i++) {
		info->iv[i] = iv[i] & 0xff;
	}

	for(i = 0; i < (keyBits / 8); i++) {
		bKey[i] = key[i] & 0xff;
	}

	AES_set_encrypt_key(bKey, keyBits, &(info->encryptKey));
	AES_set_decrypt_key(bKey, keyBits, &(info->decryptKey));

	info->decryptLast = Img3DecryptLast;
	if(!info->encrypted) {
		uint32_t sz = info->data->header->dataSize;
		if (info->decryptLast) {
			sz = info->data->header->size;
		}
		uint8_t ivec[16];
		memcpy(ivec, info->iv, 16);
		AES_cbc_encrypt(info->data->data, info->data->data, (sz / 16) * 16, &(info->decryptKey), ivec, AES_DECRYPT);
	}

	info->encrypted = TRUE;
}

Img3Element* readImg3Element(AbstractFile* file);

void freeImg3Default(Img3Element* element) {
	free(element->header);
	free(element->data);
	free(element);
}

void freeImg3Root(Img3Element* element) {
	Img3Element* current;
	Img3Element* toFree;

	free(element->header);

	current = (Img3Element*)(element->data);

	while(current != NULL) {
		toFree = current;
		current = current->next;
		toFree->free(toFree);
	}

	free(element);
}

void readImg3Root(AbstractFile* file, Img3Element* element) {
	Img3Element* children;
	Img3Element* current;
	uint32_t remaining;
	AppleImg3RootHeader* header;

	children = NULL;

	header = (AppleImg3RootHeader*) realloc(element->header, sizeof(AppleImg3RootHeader));
	element->header = (AppleImg3Header*) header;

	file->read(file, &(header->extra), sizeof(AppleImg3RootExtra));
	flipAppleImg3RootExtra(&(header->extra));

	remaining = header->base.dataSize;

	while(remaining > 0) {
		if(children != NULL) {
			current->next = readImg3Element(file);
			current = current->next;
		} else {
			current = readImg3Element(file);
			children = current;
		}
		remaining -= current->header->size;
	}

	element->data = (void*) children;
	element->write = writeImg3Root;
	element->free = freeImg3Root;
}

void writeImg3Root(AbstractFile* file, Img3Element* element, Img3Info* info) {
	AppleImg3RootHeader* header;
	Img3Element* current;
	off_t curPos;

	curPos = file->tell(file);
	curPos -= sizeof(AppleImg3Header);

	file->seek(file, curPos + sizeof(AppleImg3RootHeader));

	header = (AppleImg3RootHeader*) element->header;

	current = (Img3Element*) element->data;
	while(current != NULL) {
		if(current->header->magic == IMG3_SHSH_MAGIC) {
			header->extra.shshOffset = (uint32_t)(file->tell(file) - sizeof(AppleImg3RootHeader));
		}

		if(current->header->magic != IMG3_KBAG_MAGIC || info->encrypted) {
			writeImg3Element(file, current, info);
		}

		current = current->next;
	}

	header->base.dataSize = file->tell(file) - (curPos + sizeof(AppleImg3RootHeader));
	header->base.size = sizeof(AppleImg3RootHeader) + header->base.dataSize;

	file->seek(file, curPos);

	flipAppleImg3Header(&(header->base));
	flipAppleImg3RootExtra(&(header->extra));
	file->write(file, header, sizeof(AppleImg3RootHeader));
	flipAppleImg3RootExtra(&(header->extra));
	flipAppleImg3Header(&(header->base));

	file->seek(file, header->base.size);
}

void writeImg3Default(AbstractFile* file, Img3Element* element, Img3Info* info) {
	int sz = element->header->size - sizeof(AppleImg3Header) - element->header->dataSize;
	if (info->encrypted && element->header->magic == IMG3_DATA_MAGIC) {
		/* add "encrypted" zeros */
		file->write(file, element->data, element->header->dataSize + sz);
	} else {
		/* add "plain" zeros */
		file->write(file, element->data, element->header->dataSize);
		if (sz > 0) {
			char *zeros = calloc(1, sz);
			file->write(file, zeros, sz);
			free(zeros);
		}
	}
}

void writeImg3KBAG(AbstractFile* file, Img3Element* element, Img3Info* info) {
	flipAppleImg3KBAGHeader((AppleImg3KBAGHeader*) element->data);
	writeImg3Default(file, element, info);
	flipAppleImg3KBAGHeader((AppleImg3KBAGHeader*) element->data);
}

void do24kpwn(Img3Info* info, Img3Element* element, off_t curPos, const uint8_t* overflow, size_t overflow_size, const uint8_t* payload, size_t payload_size)
{
	off_t sizeRequired = (0x24000 + overflow_size) - curPos;
	off_t dataRequired = sizeRequired - sizeof(AppleImg3Header);
	element->data = realloc(element->data, dataRequired);
	memset(((uint8_t*)element->data) + element->header->dataSize, 0, dataRequired - element->header->dataSize);
	uint32_t overflowOffset = 0x24000 - (curPos + sizeof(AppleImg3Header));
	uint32_t payloadOffset = 0x23000 - (curPos + sizeof(AppleImg3Header));

	memcpy(((uint8_t*)element->data) + overflowOffset, overflow, overflow_size);
	memcpy(((uint8_t*)element->data) + payloadOffset, payload, payload_size);

	uint32_t* i;
	for(i = (uint32_t*)(((uint8_t*)element->data) + payloadOffset);
			i < (uint32_t*)(((uint8_t*)element->data) + payloadOffset + payload_size);
			i++) {
		uint32_t candidate = *i;
		FLIPENDIANLE(candidate);
		if(candidate == 0xDDCCBBAA) {
			candidate = info->replaceDWord;
			FLIPENDIANLE(candidate);
			*i = candidate;
			break;
		}
	}

	element->header->size = sizeRequired;
	element->header->dataSize = dataRequired;
}

void writeImg3Element(AbstractFile* file, Img3Element* element, Img3Info* info) {
	off_t curPos;

	curPos = file->tell(file);

	flipAppleImg3Header(element->header);
	file->write(file, element->header, sizeof(AppleImg3Header));
	flipAppleImg3Header(element->header);

	element->write(file, element, info);

	file->seek(file, curPos + element->header->size);
}

Img3Element* readImg3Element(AbstractFile* file) {
	Img3Element* toReturn;
	AppleImg3Header* header;
	off_t curPos;

	curPos = file->tell(file);

	header = (AppleImg3Header*) malloc(sizeof(AppleImg3Header));
	file->read(file, header, sizeof(AppleImg3Header));
	flipAppleImg3Header(header);

	toReturn = (Img3Element*) malloc(sizeof(Img3Element));
	toReturn->header = header;
	toReturn->next = NULL;

	switch(header->magic) {
		case IMG3_MAGIC:
			readImg3Root(file, toReturn);
			break;

		case IMG3_KBAG_MAGIC:
			toReturn->data = (unsigned char*) malloc(header->dataSize);
			toReturn->write = writeImg3KBAG;
			toReturn->free = freeImg3Default;
			file->read(file, toReturn->data, header->dataSize);
			flipAppleImg3KBAGHeader((AppleImg3KBAGHeader*) toReturn->data);
			break;

		default: {
			uint32_t sz = header->size - sizeof(AppleImg3Header); /* header->dataSize */
			toReturn->data = (unsigned char*) malloc(sz);
			toReturn->write = writeImg3Default;
			toReturn->free = freeImg3Default;
			file->read(file, toReturn->data, sz);
		}
	}

	file->seek(file, curPos + toReturn->header->size);

	return toReturn;
}

AbstractFile* createAbstractFileFromImg3(AbstractFile* file) {
	AbstractFile* toReturn;
	Img3Info* info;
	Img3Element* current;

	if(!file) {
		return NULL;
	}

	file->seek(file, 0);

	info = (Img3Info*) malloc(sizeof(Img3Info));
	info->file = file;
	info->root = readImg3Element(file);

	info->data = NULL;
	info->cert = NULL;
	info->kbag = NULL;
	info->type = NULL;
	info->shsh = NULL;
	info->ecid = NULL;
	info->encrypted = FALSE;

	current = (Img3Element*) info->root->data;
	while(current != NULL) {
		if(current->header->magic == IMG3_DATA_MAGIC) {
			info->data = current;
		}
		if(current->header->magic == IMG3_CERT_MAGIC) {
			info->cert = current;
		}
		if(current->header->magic == IMG3_TYPE_MAGIC) {
			info->type = current;
		}
		if(current->header->magic == IMG3_SHSH_MAGIC) {
			info->shsh = current;
		}
		if(current->header->magic == IMG3_ECID_MAGIC) {
			info->ecid = current;
		}
		if(current->header->magic == IMG3_KBAG_MAGIC && ((AppleImg3KBAGHeader*)current->data)->key_modifier == 1) {
			info->kbag = current;
		}
		current = current->next;
	}

	info->offset = 0;
	info->dirty = FALSE;
	info->encrypted = FALSE;
	info->decryptLast = FALSE;

	toReturn = (AbstractFile*) malloc(sizeof(AbstractFile2));
	toReturn->data = info;
	toReturn->read = readImg3;
	toReturn->write = writeImg3;
	toReturn->seek = seekImg3;
	toReturn->tell = tellImg3;
	toReturn->getLength = getLengthImg3;
	toReturn->close = closeImg3;
	toReturn->type = AbstractFileTypeImg3;

	AbstractFile2* abstractFile2 = (AbstractFile2*) toReturn;
	abstractFile2->setKey = setKeyImg3;

	if(info->kbag) {
		uint8_t* keySeed;
		uint32_t keySeedLen;
		keySeedLen = 16 + (((AppleImg3KBAGHeader*)info->kbag->data)->key_bits)/8;
		keySeed = (uint8_t*) malloc(keySeedLen);
		memcpy(keySeed, (uint8_t*)((AppleImg3KBAGHeader*)info->kbag->data) + sizeof(AppleImg3KBAGHeader), keySeedLen);
#ifdef HAVE_HW_CRYPTO
		printf("Have hardware crypto\n");
		CFMutableDictionaryRef dict = IOServiceMatching("IOAESAccelerator");
		io_service_t dev = IOServiceGetMatchingService(kIOMasterPortDefault, dict);
		io_connect_t conn = 0;
		IOServiceOpen(dev, mach_task_self(), 0, &conn);

		int i;
		printf("KeySeed: ");
		for(i = 0; i < keySeedLen; i++)
		{
			printf("%02x", keySeed[i]);
		}
		printf("\n");

		if(doAES(conn, keySeed, keySeed, keySeedLen, GID, NULL, NULL, kIOAESAcceleratorDecrypt) == 0) {
			unsigned int key[keySeedLen - 16];
			unsigned int iv[16];

			printf("IV: ");
			for(i = 0; i < 16; i++)
			{
				iv[i] = keySeed[i];
				printf("%02x", iv[i]);
			}
			printf("\n");

			printf("Key: ");
			for(i = 0; i < (keySeedLen - 16); i++)
			{
				key[i] = keySeed[i + 16];
				printf("%02x", key[i]);
			}
			printf("\n");

			setKeyImg3(abstractFile2, key, iv);
		}

		IOServiceClose(conn);
		IOObjectRelease(dev);
#else
		int i = 0;
		char outputBuffer[256];
		char curBuffer[256];
		outputBuffer[0] = '\0';
		for(i = 0; i < keySeedLen; i++) {
			sprintf(curBuffer, "%02x", keySeed[i]);
			strcat(outputBuffer, curBuffer);
		}
		strcat(outputBuffer, "\n");
#endif
		free(keySeed);
	}

	return toReturn;
}

void replaceCertificateImg3(AbstractFile* file, AbstractFile* certificate) {
	Img3Info* info = (Img3Info*) file->data;

	info->cert->header->dataSize = certificate->getLength(certificate);
	info->cert->header->size = info->cert->header->dataSize + sizeof(AppleImg3Header);
	if(info->cert->data != NULL) {
		free(info->cert->data);
	}
	info->cert->data = malloc(info->cert->header->dataSize);
	certificate->read(certificate, info->cert->data, info->cert->header->dataSize);

	info->dirty = TRUE;
}

void replaceSignatureImg3(AbstractFile* file, AbstractFile* signature) {
  Img3Info* info = (Img3Info*) file->data;
  
  size_t signature_size = signature->getLength(signature);
  Img3Element* element = (Img3Element*) readImg3Element(signature);

  int i = 0;
  Img3Element* previous = element;
  for (i = previous->header->size; i < signature_size; i += previous->header->size) {
    previous->next = (Img3Element*) readImg3Element(signature);
    previous = previous->next;
  }

  Img3Element* current = info->data;
  while (current->next != info->shsh) {
    current = current->next;
  }

  signature->seek(signature, 0);
  current->next = element;
  info->dirty = TRUE;
}

AbstractFile* duplicateImg3File(AbstractFile* file, AbstractFile* backing) {
	Img3Info* info;
	AbstractFile* toReturn;

	if(!file) {
		return NULL;
	}

	toReturn = createAbstractFileFromImg3(((Img3Info*)file->data)->file);
	info = (Img3Info*)toReturn->data;

	info->file = backing;
	info->offset = 0;
	info->dirty = TRUE;
	info->data->header->dataSize = 0;
	info->data->header->size = info->data->header->dataSize + sizeof(AppleImg3Header);

	return toReturn;
}

