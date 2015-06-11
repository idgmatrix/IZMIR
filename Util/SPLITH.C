/***************************************************************
    splith.c  (c) 1994, 1995 Mirinae Software ,Inc.
    code : KIM SEONG WAN

    1994. 7  Header split 1.0 handle only 128 bytes header
    1995. 1. 1  Version 1.1 handle any size of header
			    some bug fixed
    memory model : large
****************************************************************/


#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <alloc.h>
#include <string.h>
#include <dir.h>

typedef unsigned char byte;

unsigned int page_num;
unsigned int page_etc;
unsigned long data_size;
FILE *sfp, *tfp;

char path[80];
char drive[3],dir[66],name[9],ext[5];
int i;
int hsize;
char *head_buffer;
char *buffer;

int main(int argc, char *argv[])
{
	char fname[20];

	if (argc<2)
	{
		printf("Header split 1.2 (c) 1994-1995 Mirinae Software, Inc.\n\n");
		printf("Usage : SPLITH filename [n]\n");
		printf("        [n] header size in bytes\n");
		printf("            default 128\n");
		return 1;
	}

	buffer = malloc(32768);

	getcwd(path,80);
	strcat(path, "\\");
	strcat(path, argv[1]);
	fnsplit(path,drive,dir,name,ext);

	if ((sfp = fopen(argv[1], "rb")) == NULL)
	{
	   printf("Cannot open input file.\n");
	   exit(1);
	}

	if ( argc < 3 ) hsize = 128;
	else hsize = atoi(argv[2]);

	head_buffer = malloc(hsize);

	data_size = filelength(fileno(sfp)) - hsize;

	fread(head_buffer,hsize,1,sfp);

	strncpy(fname,name,8);
	fname[8]='\0';
	strcat(fname,".hdr");

	if ((tfp = fopen(fname, "wb")) == NULL)
	{
		printf("Cannot open output file.\n");
		exit(0);
	}
	printf("writing file : %s\n",fname);
	if (fwrite(head_buffer,1,hsize,tfp)!=hsize)
	{
		printf("1Write error or disk full");
		exit(1);
	}
	fclose(tfp);

	strncpy(fname,name,8);
	fname[8]='\0';
	strcat(fname,".bod");

	if ((tfp = fopen(fname, "wb")) == NULL)
	{
		printf("\nCannot open output file.\n");
		exit(0);
	}

	printf("Writing file : %s\n",fname);

	page_num = data_size / 32768;
	page_etc = data_size % 32768;

	for ( i=0;i<page_num;i++ )
	{
		fread(buffer,32768,1,sfp);
		if (fwrite(buffer,32768,1,tfp)!=32768)
		{
			printf("\n2Write error or Disk full");
			exit(1);
		}
	}

	if ( page_etc )
	{
		fread(buffer,page_etc,1,sfp);
		if (fwrite(buffer,1,page_etc,tfp)!=page_etc)
		{
			printf("\n3Write error or Disk full");
			exit(1);
		}
	}

	fclose(sfp);
	fclose(tfp);

	return 0;
}
