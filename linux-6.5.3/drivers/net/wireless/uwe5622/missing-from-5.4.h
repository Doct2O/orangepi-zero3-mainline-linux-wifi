#ifndef MISSING_FROM_5_4_H
#define MISSING_FROM_5_4_H
#include <linux/ktime.h>
#include <linux/timekeeping.h>
#include <linux/time64.h>

typedef unsigned short __kernel_old_gid_t;
typedef long            __kernel_long_t;
typedef __kernel_long_t __kernel_time_t;
struct timespec {
        __kernel_time_t tv_sec;                 /* seconds */
        long            tv_nsec;                /* nanoseconds */
};

/* Undeclared despite including uapi/linux/time.h previously. Decided to put it verbosely here.*/
struct timeval {
	__kernel_old_time_t	tv_sec;		/* seconds */
	__kernel_suseconds_t	tv_usec;	/* microseconds */
};

static inline s64 timespec_to_ns(const struct timespec *ts)
{
        return ((s64) ts->tv_sec * NSEC_PER_SEC) + ts->tv_nsec;
}

static inline struct timespec timespec64_to_timespec(const struct timespec64 ts64)
{
        return *(const struct timespec *)&ts64;
}

static inline void getnstimeofday(struct timespec *ts)
{
        struct timespec64 ts64;

        ktime_get_real_ts64(&ts64);
        *ts = timespec64_to_timespec(ts64);
}

static inline s64 timeval_to_ns(const struct timeval *tv)
{
	return ((s64) tv->tv_sec * NSEC_PER_SEC) + tv->tv_usec * NSEC_PER_USEC;
}

#endif /* MISSING_FROM_5_4_H */
