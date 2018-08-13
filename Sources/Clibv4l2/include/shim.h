#include <linux/videodev2.h>

#define EXPORT(x, t) \
static const t _##x = x;

EXPORT(VIDIOC_G_FMT,        unsigned long)
EXPORT(VIDIOC_S_FMT,        unsigned long)
EXPORT(VIDIOC_QBUF,         unsigned long)
EXPORT(VIDIOC_DQBUF,        unsigned long)
EXPORT(VIDIOC_REQBUFS,      unsigned long)
EXPORT(VIDIOC_QUERYBUF,		  unsigned long)
EXPORT(VIDIOC_QUERYCAP,     unsigned long)
EXPORT(VIDIOC_CROPCAP,      unsigned long)
EXPORT(VIDIOC_S_CROP,       unsigned long)
EXPORT(VIDIOC_STREAMON,     unsigned long)
EXPORT(VIDIOC_STREAMOFF,    unsigned long)

EXPORT(V4L2_PIX_FMT_RGB24, 	unsigned int)
EXPORT(V4L2_PIX_FMT_NV12, 	unsigned int)
EXPORT(V4L2_PIX_FMT_RGB32, 	unsigned int)
EXPORT(V4L2_PIX_FMT_YUYV, 	unsigned int)
EXPORT(V4L2_PIX_FMT_YUV420, unsigned int)
