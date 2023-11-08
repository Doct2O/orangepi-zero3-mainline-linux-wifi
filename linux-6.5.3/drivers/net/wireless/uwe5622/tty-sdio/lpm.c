#include <linux/module.h>
#include <linux/errno.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/proc_fs.h>
#include <linux/uaccess.h>
#include <linux/ioport.h>
#include <linux/param.h>
#include <linux/bitops.h>
#include <linux/gpio.h>
#include <linux/seq_file.h>
#include <linux/version.h>
#include <linux/export.h>
#include <marlin_platform.h>

#include "../../../../../fs/proc/internal.h"

#define VERSION         "marlin2 V0.1"
#define PROC_DIR        "bluetooth/sleep"

#ifndef FALSE
#define FALSE       0
#endif
#ifndef TRUE
#define TRUE        1
#endif

extern struct wakeup_source *wakeup_source_create(const char *name);
extern void wakeup_source_destroy(struct wakeup_source *ws);
extern void wakeup_source_add(struct wakeup_source *ws);
extern void wakeup_source_remove(struct wakeup_source *ws);
extern struct wakeup_source *wakeup_source_register(struct device *dev,
                                                   const char *name);
extern void wakeup_source_unregister(struct wakeup_source *ws);
extern int wakeup_sources_read_lock(void);
extern void wakeup_sources_read_unlock(int idx);
extern struct wakeup_source *wakeup_sources_walk_start(void);
extern struct wakeup_source *wakeup_sources_walk_next(struct wakeup_source *ws);
extern int device_wakeup_enable(struct device *dev);
extern int device_wakeup_disable(struct device *dev);
extern void device_set_wakeup_capable(struct device *dev, bool capable);
extern int device_set_wakeup_enable(struct device *dev, bool enable);
extern void __pm_stay_awake(struct wakeup_source *ws);
extern void pm_stay_awake(struct device *dev);
extern void __pm_relax(struct wakeup_source *ws);
extern void pm_relax(struct device *dev);
extern void pm_wakeup_ws_event(struct wakeup_source *ws, unsigned int msec, bool hard);
extern void pm_wakeup_dev_event(struct device *dev, unsigned int msec, bool hard);

static inline void __pm_wakeup_event(struct wakeup_source *ws, unsigned int msec)
{
       return pm_wakeup_ws_event(ws, msec, false);
}

static inline void * PDE_DATA(struct inode *inode)
{
        return (struct mdbg_proc_entry *) PDE(inode)->data;
}


struct proc_dir_entry *bluetooth_dir, *sleep_dir;
struct wakeup_source *tx_ws;
struct wakeup_source *rx_ws;

void host_wakeup_bt(void)
{
	__pm_stay_awake(tx_ws);
	marlin_set_sleep(MARLIN_BLUETOOTH, FALSE);
	marlin_set_wakeup(MARLIN_BLUETOOTH);
}

void bt_wakeup_host(void)
{
	__pm_relax(tx_ws);
	__pm_wakeup_event(rx_ws, jiffies_to_msecs(HZ * 5));
}

static ssize_t bluesleep_write_proc_btwrite(struct file *file,
	const char __user *buffer, size_t count, loff_t *pos)
{
	char b;

	if (count < 1)
		return -EINVAL;
	if (copy_from_user(&b, buffer, 1))
		return -EFAULT;
	pr_info("bluesleep_write_proc_btwrite=%d\n", b);
	if (b == '1')
		host_wakeup_bt();
	else if (b == '2') {
		marlin_set_sleep(MARLIN_BLUETOOTH, TRUE);
		__pm_relax(tx_ws);
	} else
		pr_err("bludroid pass a unsupport parameter");
	return count;
}

static int btwrite_proc_show(struct seq_file *m, void *v)
{
	/*unsigned int btwrite;*/
	pr_info("bluesleep_read_proc_lpm\n");
	seq_puts(m, "unsupported to read\n");
	return 0;
}

static int bluesleep_open_proc_btwrite(struct inode *inode, struct file *file)
{
	return single_open(file, btwrite_proc_show, PDE_DATA(inode));
}

/* static const struct file_operations lpm_proc_btwrite_fops = {
	.owner = THIS_MODULE,
	.open = bluesleep_open_proc_btwrite,
	.read = seq_read,
	.write = bluesleep_write_proc_btwrite,
	.release = single_release,
}; */

static const struct proc_ops lpm_proc_btwrite_fops = {
       /*.owner = THIS_MODULEi,*/
       .proc_open = bluesleep_open_proc_btwrite,
       .proc_read = seq_read,
       .proc_write = bluesleep_write_proc_btwrite,
       .proc_release = single_release,
};

/*static int __init bluesleep_init(void)*/
int  bluesleep_init(void)
{
	int retval;
	struct proc_dir_entry *ent;

	bluetooth_dir = proc_mkdir("bluetooth", NULL);
	if (bluetooth_dir == NULL) {
		pr_info("Unable to create /proc/bluetooth directory");
		remove_proc_entry("bluetooth", 0);
		return -ENOMEM;
	}
	sleep_dir = proc_mkdir("sleep", bluetooth_dir);
	if (sleep_dir == NULL) {
		pr_info("Unable to create /proc/%s directory", PROC_DIR);
		remove_proc_entry("bluetooth", 0);
		return -ENOMEM;
	}

	/* Creating read/write  entry */
	ent = proc_create("btwrite", S_IRUGO | S_IWUSR | S_IWGRP, sleep_dir,
		&lpm_proc_btwrite_fops); /*read/write */
	if (ent == NULL) {
		pr_info("Unable to create /proc/%s/btwake entry",
			PROC_DIR);
		retval = -ENOMEM;
		goto fail;
	}
	tx_ws = wakeup_source_create("BT_TX_wakelock");
	rx_ws = wakeup_source_create("BT_RX_wakelock");
	wakeup_source_add(tx_ws);
	wakeup_source_add(rx_ws);
	return 0;

fail:
	remove_proc_entry("btwrite", sleep_dir);
	remove_proc_entry("sleep", bluetooth_dir);
	remove_proc_entry("bluetooth", 0);
	wakeup_source_remove(tx_ws);
	wakeup_source_remove(rx_ws);
	wakeup_source_destroy(tx_ws);
	wakeup_source_destroy(rx_ws);
	return retval;
}

/*static void __exit bluesleep_exit(void)*/
void  bluesleep_exit(void)
{
	remove_proc_entry("btwrite", sleep_dir);
	remove_proc_entry("sleep", bluetooth_dir);
	remove_proc_entry("bluetooth", 0);
	wakeup_source_remove(tx_ws);
	wakeup_source_remove(rx_ws);
	wakeup_source_destroy(tx_ws);
	wakeup_source_destroy(rx_ws);
}

/*module_init(bluesleep_init);*/
/*module_exit(bluesleep_exit);*/
MODULE_DESCRIPTION("Bluetooth Sleep Mode Driver ver %s " VERSION);
MODULE_LICENSE("GPL");
