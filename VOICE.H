#ifndef _VOICE_MAIN_SOURCE_
extern short VoiceFlag;     /* ���� ��� ���� ���� */
extern short SBLBaseIO;     /* default sound blaster Base IO Address */
extern short SBLIRQ;        /* default sound blaster hardware interrupt */
extern short SBLDMAChannel; /* default sound blaster DMA channel */
extern unsigned short SampleRate;
extern unsigned char MultiVoice;
#endif

#ifndef _VOICE_HEADER_
#define _VOICE_HEADER_

/* ���� ��� �ϵ���� ���� */

#define NO_VOICE      0 /* ���� ����� ���� �ʴ´�. */
#define SOUNDBLASTER  1 /* ���� �������� */

#define VOICE_IDLE 0    /* ���� ������� �ƴϴ�. */
#define VOICE_BUSY 1    /* ���� ������̴�. */

#define DIRECT_8BIT_DAC 0x10  /* ��� ���� 8 ��Ʈ DAC */
#define DMA_8BIT_DAC    0x14  /* DMA�� �̿��� 8 ��Ʈ DAC */
#define HALT_DMA        0xd0  /* DMA ���� ���� */
#define FREQ_DIVISER    0x40  /* ���ø� ���ļ� ���� */
#define SBL_SPEAKER_ON  0xD1  /* ��� ����Ŀ�� �Ҵ�. */
#define SBL_SPEAKER_OFF 0xD3  /* ��� ����Ŀ�� ����. */
#define SBL_RESET       0x6   /* ��� ���V */
#define SBL_RESET_CMD   0x1
#define SBL_DATA_AVAIL  0x0e  /* ��� ����Ÿ �м��� */
#define SBL_READ_DATA   0xa   /* ��� ����Ÿ �б� */
#define SBL_READ_STATUS 0xc   /* ��� ���� �б� */
#define SBL_WRITE_DATA  0xc   /* ��� ����Ÿ ���� */

#define SBLPRO_MIXER_A  0x4   /* ��� ���� �ͼ� ��巹�� */
#define SBLPRO_MIXER_D  0x5   /* ��� ���� �ͼ� ����Ÿ ��巹�� */

#define SBLPRO_VOICE_VOLUME   0x04 /* ��� ���� ���̽� ���� */
#define SBLPRO_MASTER_VOLUME  0x22
#define SBLPRO_LINE_VOLUME    0x2e
#define SBLPRO_FM_VOLUME      0x26
#define SBLPRO_CD_VOLUME      0x28

#define setSBLProMixer(A,R,L) \
  { outp(SBLBaseIO+SBLPRO_MIXER_A,(A)) ; \
    outp(SBLBaseIO+SBLPRO_MIXER_D,((R)<<4)|(L)) ; }

#define sayVoice(F)    sayPCM((F),0)

/* ���� ����� ������ ���� ��ٸ���. */
#define waitVoiceEnd()    while(VoiceFlag==VOICE_BUSY)


/* VOICE.C procedure */
void *DosMalloc(unsigned long size);
int DosFree(unsigned char * ptr);
int SBLCommand(unsigned char cmd) ;
int SBLSendCommand(unsigned char cmd) ;
int SBLReset(short BaseIO) ;
void SBLSpeaker(short flag) ;
void SBLOnePulseDA(unsigned char PCMData) ;
void endVoice(void) ;
int initVoice(short SndDev) ;
void setPCMVolume(unsigned short vl,unsigned short vr) ;
void setSampleRate(unsigned short sampleRate) ;
int silentVoice(short flag) ;
int sayPCM(unsigned char *PCMData,unsigned short l) ;
void sayDMAVoice(long physical,unsigned short l) ;
unsigned short getVoiceRemainSample(void) ;
void setSoundBlasterENV(short BaseIO,short IRQ,short DMAChannel) ;
int SBLAutoDetect(void) ;
void waitmSec(unsigned short mSec) ;

#endif
