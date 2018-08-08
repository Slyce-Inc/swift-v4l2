#include <linux/videodev2.h>

#define EXPORT(x, t) \
static const t _##x = x;

EXPORT(VIDIOC_G_FMT,            unsigned int)
EXPORT(VIDIOC_S_FMT,            unsigned int)
EXPORT(VIDIOC_QBUF,             unsigned int)
EXPORT(VIDIOC_DQBUF,            unsigned int)
EXPORT(VIDIOC_REQBUFS,          unsigned int)
EXPORT(VIDIOC_QUERYBUF,		unsigned int)

EXPORT(V4L2_PIX_FMT_RGB24, 	unsigned int)
EXPORT(V4L2_PIX_FMT_NV12, 	unsigned int)
EXPORT(V4L2_PIX_FMT_RGB32, 	unsigned int)
EXPORT(V4L2_PIX_FMT_YUYV, 	unsigned int)
EXPORT(V4L2_PIX_FMT_YUV420, unsigned int)
