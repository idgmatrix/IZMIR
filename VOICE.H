#ifndef _VOICE_MAIN_SOURCE_
extern short VoiceFlag;     /* 음성 출력 상테 변수 */
extern short SBLBaseIO;     /* default sound blaster Base IO Address */
extern short SBLIRQ;        /* default sound blaster hardware interrupt */
extern short SBLDMAChannel; /* default sound blaster DMA channel */
extern unsigned short SampleRate;
extern unsigned char MultiVoice;
#endif

#ifndef _VOICE_HEADER_
#define _VOICE_HEADER_

/* 음성 출력 하드웨어 정의 */

#define NO_VOICE      0 /* 음성 출력을 하지 않는다. */
#define SOUNDBLASTER  1 /* 사운드 블래스터 */

#define VOICE_IDLE 0    /* 음성 출력중이 아니다. */
#define VOICE_BUSY 1    /* 음성 출력중이다. */

#define DIRECT_8BIT_DAC 0x10  /* 사블 직접 8 비트 DAC */
#define DMA_8BIT_DAC    0x14  /* DMA를 이용한 8 비트 DAC */
#define HALT_DMA        0xd0  /* DMA 전송 중지 */
#define FREQ_DIVISER    0x40  /* 샘플링 주파수 설정 */
#define SBL_SPEAKER_ON  0xD1  /* 사블 스피커를 켠다. */
#define SBL_SPEAKER_OFF 0xD3  /* 사블 스피커를 끈다. */
#define SBL_RESET       0x6   /* 사블 리셑 */
#define SBL_RESET_CMD   0x1
#define SBL_DATA_AVAIL  0x0e  /* 사블 데이타 분석중 */
#define SBL_READ_DATA   0xa   /* 사블 데이타 읽기 */
#define SBL_READ_STATUS 0xc   /* 사블 상태 읽기 */
#define SBL_WRITE_DATA  0xc   /* 사블 데이타 쓰기 */

#define SBLPRO_MIXER_A  0x4   /* 사블 프로 믹서 어드레스 */
#define SBLPRO_MIXER_D  0x5   /* 사블 프로 믹서 데이타 어드레스 */

#define SBLPRO_VOICE_VOLUME   0x04 /* 사블 프로 보이스 볼륨 */
#define SBLPRO_MASTER_VOLUME  0x22
#define SBLPRO_LINE_VOLUME    0x2e
#define SBLPRO_FM_VOLUME      0x26
#define SBLPRO_CD_VOLUME      0x28

#define setSBLProMixer(A,R,L) \
  { outp(SBLBaseIO+SBLPRO_MIXER_A,(A)) ; \
    outp(SBLBaseIO+SBLPRO_MIXER_D,((R)<<4)|(L)) ; }

#define sayVoice(F)    sayPCM((F),0)

/* 음성 출력이 끝날때 까지 기다린다. */
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

