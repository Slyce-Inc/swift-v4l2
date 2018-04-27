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
