

## **Lab 2 – File Open Counter (Kernel Module)**

### **Objective**

In this lab, you will create a Linux Kernel Module that exposes a counter via `/proc/trace_opencount`.
Each time the file is opened (e.g., using `cat`), a counter is incremented. The current count is displayed when the file is read.


---

### Provided files

**`open_counter.c`**

```c
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/proc_fs.h>
#include <linux/uaccess.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("KernelLab");
MODULE_DESCRIPTION("Count file opens via /proc");

#define PROC_NAME "trace_opencount"

static struct proc_dir_entry *proc_file;
static unsigned long total_opens = 0;

static int open_counter_open(struct inode *inode, struct file *file)
{
    total_opens++;
    return 0;
}

static ssize_t open_counter_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
{
    char buffer[128];
    int len;

    len = snprintf(buffer, sizeof(buffer), "Files opened since module load: %lu\n", total_opens);
    return simple_read_from_buffer(buf, count, ppos, buffer, len);
}

static const struct file_operations open_counter_fops = {
    .owner = THIS_MODULE,
    .open = open_counter_open,
    .read = open_counter_read,
};

static int __init open_counter_init(void)
{
    proc_file = proc_create(PROC_NAME, 0444, NULL, &open_counter_fops);
    if (!proc_file)
        return -ENOMEM;

    pr_info("[open_counter] Module loaded\n");
    return 0;
}

static void __exit open_counter_exit(void)
{
    proc_remove(proc_file);
    pr_info("[open_counter] Module unloaded\n");
}

module_init(open_counter_init);
module_exit(open_counter_exit);
```

---

### **Tasks to complete**

1. Compile the module.
2. Insert the module into the kernel.
3. Open `/proc/trace_opencount` several times.
4. Observe how the value increments.
5. Remove the module.


---

### **Expected output**

```bash
$ cat /proc/trace_opencount
Files opened since module load: 3
```

