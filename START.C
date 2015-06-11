/*****************************************************
  IZMIR start up C code
******************************************************/
#include <stdio.h>
#include <io.h>
#include <i86.h>
#include <stdlib.h>

#include "voice.h"

// int soundpar = 0;
int stagepar = 1;
unsigned char *vocfn[13] ={"izbeam1.mrv",
			   "izbomb2.mrv",
			   "iz01.mrv",
			   "iz02.mrv",
			   "iz03.mrv",
			   "iz04.mrv",
			   "iz05.mrv",
			   "iz06.mrv",
			   "iz07.mrv",
			   "iz08.mrv",
			   "iz09.mrv",
			   "iz10.mrv",
			   "iz11.mrv"};
extern unsigned char *PCMptr;
extern unsigned char *vptr[13];
extern unsigned short l[13];

extern void start(void);

void Intro(void)
{
	union REGS regs;

	regs.w.ax = 0x3;
	int386(0x10,&regs,&regs);

	printf("IZMIR Version 1.0\n");
	printf("3D Shooting Game.\n");
	printf("Copyright (c) 1995 MIRINAE Software, Inc.\n\n");
}

int sound_init(void)
{
	FILE *fp;
	unsigned short i;

	for (i = 0;i < 13;i++)
	{
		if ((fp = fopen(vocfn[i],"rb"))==NULL) return(-1);

		if (filelength(fileno(fp)) > 64000L) l[i] = 64000;
		else l[i] = (unsigned short)filelength(fileno(fp));

		vptr[i] = malloc(l[i]);

		if (vptr[i]==NULL)
		{
			silentVoice(0);
			fclose(fp); return(-2);
		}

		fread(vptr[i],1,l[i],fp);
		fclose(fp);
	}
/*
	if (SBLAutoDetect()<1)
	{
		printf("Sound Card not Found !\n");
	};
	printf("SB IRQ : %d\n", SBLIRQ);
	printf("SB DMA CHANNEL : %d\n", SBLDMAChannel);

	initVoice(SOUNDBLASTER);

	setSampleRate(8000) ;
*/
//      for ( i = 0; i < 64000l; i++) *(PCMptr + i) = 128;

//      sayPCM(vptr[0],l[0]);
//      sayPCM(vptr[1],l[1]);

	return(0);
}

main(int argc, char *argv[])
{
	int i;

	Intro();

	if(argc > 1)
	{
//              soundpar = atoi(argv[1]);
		stagepar = atoi(argv[1]);
//              if (stagepar > 7) stagepar = 7;
		stagepar = 1;
//              if (soundpar == 0) { soundpar = 1; goto there;}
//              else soundpar = 0;
	}

	if( sound_init() < 0 ) { printf("Voice file loading error"); return;}
//there:
//      printf("Press any key to start...\n");
	start();

//      for(i=100;i<120;i++)
//      printf("%d  :   %d\n",i,FindSqrt(i));

	for(i=0;i<12;i++) free(vptr[i]);

	endVoice();
	printf("Thanks for playing IZMIR");
}

