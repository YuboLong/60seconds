#!/bin/bash -       
#title           :Inspired from "Linux Performance Analysis in 60,000 Milliseconds" http://techblog.netflix.com/2015/11/linux-performance-analysis-in-60s.html
#description     :This script will run a serie of tests
#author          :Aymen El Amri
#github          :
#date            :2015-12-21
#version         :0.1
#usage           :bash ${SCRIPT_NAME} [-b]
#notes           :
#bash_version    :4.3.11(1)-release
#===============================================================================
for i in "$@"
do
case $i in
    -b|--batch)
    BATCH=1
    shift # past argument=value
    ;;

    -e|--explain)
    EXPLAIN=1
    shift # past argument=value
    ;;
    
    *)
    ;;
esac
done

seq(){
    if [ -z "$BATCH" ]; then echo -e "\e[31m type [enter] \e[0m"; read -p ""; fi
}

explain(){
    if [ -z "$EXPLAIN" ]; then echo -e "\e[36m $1 \e[0m"; fi
}

echo -e "\e[31m ========================================================\e[0m"
echo -e "\e[31m uptime -- CPU load/how long the system has been running \e[0m"
echo -e "\e[31m ========================================================\e[0m"
uptime

e="THE TRAFFIC ANALOGY: http://blog.scoutapp.com/articles/2009/07/31/understanding-load-averages
0.00 表示机器目前空载\n
1.00 表示满载(多核机器需要乘以CPU核数,4核CPU下4就表示满载)\n
超过1*CPU_CORE表示已经处理不过来了.该指标是Running还有Ready态任务数的和
"
explain "$e"
seq
#
echo -e "\e[31m =======================================\e[0m"
echo -e "\e[31m dmesg -- 系统事件，注意有没有OOM Killer  \e[0m"
echo -e "\e[31m =======================================\e[0m"
dmesg -T | tail
seq
#
echo -e "\e[31m ===========================================================\e[0m"
echo -e "\e[31m vmstat -- virtual memory statistics in MB (一秒一次，刷四次) \e[0m"
echo -e "\e[31m =========================================================== \e[0m"
vmstat -S m 1 4


e="
Procs
    r: Ready态的进程数量，包括正在运行的
    b: 不可中断的进程数量（通常是磁盘IO操作)
Memory
    swpd: 虚拟内存(virtual memory)使用总量
    free: 空闲内存(idle memory)总量
    buff: 被用作Buffer的内存总量
    cache: 被用作Cache的内存总量
    inact: the amount of inactive memory. (-a option)
    active: the amount of active memory. (-a option)
Swap
    si: 从磁盘换入内存的量
    so: 从内存换出到磁盘的量
IO
    bi: 从块设备读取到的块数(blocks/s)
    bo: 写入到块设备的块数 (blocks/s).
System
    in: 每秒中断数，包括定时时钟产生的
    cs: 每秒的上下文切换次数(按照经验，java程序单核10k就基本满载了)
CPU
    CPU时间相关
    us: 用户态时间（非内核态时间）
    sy: 内核态时间
    id: 空闲时间
    wa: 等待IO的时间
    st: 被偷走的时间，云主机环境通常都是其他机器的影响(按经验5%以上就会影响到应用程序)
    "

explain "$e"
seq
#
echo -e "\e[31m =============================\e[0m"
echo -e "\e[31m mpstat -- CPU相关统计         \e[0m"
echo -e "\e[31m ============================= \e[0m"
mpstat -P ALL 1 1
e="

all: means All CPUs
%usr: 用户态代码时间百分比
%nice: show the percentage of CPU utilization that occurred while executing at the user level with nice priority(越大优先级越低，越小优先级越高)
%sys: 内核态代码时间百分比
%iowait: IO等待时间
%irq: 处理硬件中断
%soft: 处理软件中断
%steal: 被偷走的时间
%guest: show the percentage of time spent by the CPU or CPUs to run a virtual processor
%idle: 空闲时间
"
explain "$e"
seq
#
echo -e "\e[31m ========================== \e[0m"
echo -e "\e[31m pidstat -- 进程统计         \e[0m"
echo -e "\e[31m ========================== \e[0m"
pidstat 1 1

e="
UID: The real user identification number of the task being monitored.
USER: The real user name of the task being monitored.
PID: 进程号

%usr: 用户态代码时间百分比
%system: 内核态代码时间百分比
%guest: Percentage of CPU spent by the task in virtual machine (running a virtual processor).
%CPU: Total percentage of CPU time used by the task. In an SMP environment, the task's CPU usage will be divided by the total number of CPU's if option -I has been entered on the command line.

CPU: 执行任务的CPU编号.
Command: The command name of the task."
explain "$e"
seq
#
echo -e "\e[31m ===================================================================== \e[0m"
echo -e "\e[31m iostat -- CPU 和IO 统计 \e[0m"
echo -e "\e[31m ===================================================================== \e[0m"
iostat -xz 1 1

e="
%user: 用户态代码时间百分比
%nice:  CPU utilization that occurred while executing at the user level with nice priority.
%system:  内核态代码时间百分比
%iowait:  IO等待时间
%steal:  被其他虚拟CPU占用的时间
%idle:  空闲

rrqm/s  每秒钟被合并的读请求（queued）
wrqm/s   每秒钟被合并的写请求（queued）
r/s  每秒钟的读请求
w/s  每秒钟的写请求
rMB/s    每秒钟的读MB
wMB/s    每秒钟的写MB
avgrq-sz 平均每次设备I/O操作的数据大小 (扇区)
avgqu-sz 平均I/O队列长度。
await   平均每次设备I/O操作的等待时间 ，包括等待时间和操作时间(毫秒)。
r_await 平均每次读设备I/O操作的等待时间，包括等待时间和操作时间 (毫秒)。
w_await 平均每次写设备I/O操作的等待时间 ，包括等待时间和操作时间(毫秒)。
svctm   平均每次设备I/O操作的服务时间 (毫秒) - 不要信任这个值，未来会被移除
%util    被io消耗的cpu百分比，100%即饱和 "
explain "$e"
seq
#
echo -e "\e[31m ================================== \e[0m"
echo -e "\e[31m free and used memory in the system \e[0m"
echo -e "\e[31m ================================== \e[0m"
free -m

e="
total: 全部物理RAM大小 (不包括内核启动永久占用的部分，所以你有16G内存，这里可能显示15.7G); 
used: 已使用的内存
free: 未使用的内存
total: 已使用的内存 + 未使用的内存
shared / buffers / cached: 特定目的被占用的，已经包括在used里面了"
explain "$e"
seq
#
echo -e "\e[31m ==================================== \e[0m"
echo -e "\e[31m sar -n DEV --网络设备信息 \e[0m"
echo -e "\e[31m ==================================== \e[0m"
sar -n DEV 1 1
e="
IFACE
       网络接口名
rxpck/s
       每秒接受到的package数量
txpck/s
       每秒发送的package数量
rxkB/s
       每秒接受的数据量kb
txkB/s
        每秒发送的数据量kb
rxcmp/s
       Number of compressed packets received per second (for cslip etc.).
txcmp/s
       Number of compressed packets transmitted per second.
rxmcst/s
       Number of multicast packets received per second.
%ifutil
       网络接口使用率.  "
explain "$e"
seq
#
echo -e "\e[31m ======================================== \e[0m"
echo -e "\e[31m sar -n TCP -- TCPv4 activity information \e[0m"
echo -e "\e[31m ======================================== \e[0m"
sar -n TCP 1 1

e="
active/s
       每秒钟从CLOSED到SYN-SENT的数量[通常是客户端发起的请求tcpActiveOpens].
passive/s
       每秒钟从LISTEN到SYN-RCVD的数量[通常是服务端监听的请求tcpPassiveOpens].  
iseg/s
       The total number of segments received per second, including those received in error [tcpInSegs].  This count  includes  segments
       received on currently established connections.
oseg/s
       The  total  number  of  segments  sent  per  second,  including those on current connections but excluding those containing only
       retransmitted octets [tcpOutSegs]."
explain "$e"
seq
#
echo -e "\e[31m ========================== \e[0m"
echo -e "\e[31m TCPv4 activity information \e[0m"
echo -e "\e[31m ========================== \e[0m"
sar -n ETCP 1 1

e="
atmptf/s
       The  number of times per second TCP connections have made a direct transition to the CLOSED state from either the SYN-SENT state
       or the SYN-RCVD state, plus the number of times per second TCP connections have made a direct transition  to  the  LISTEN  state
       from the SYN-RCVD state [tcpAttemptFails].
estres/s
       The  number  of  times  per second TCP connections have made a direct transition to the CLOSED state from either the ESTABLISHED
       state or the CLOSE-WAIT state [tcpEstabResets].
retrans/s
       The total number of segments retransmitted per second - that is, the number of TCP segments transmitted containing one  or  more
       previously transmitted octets [tcpRetransSegs].
isegerr/s
       The total number of segments received in error (e.g., bad TCP checksums) per second [tcpInErrs].
orsts/s
       The number of TCP segments sent per second containing the RST flag [tcpOutRsts]."
explain "$e"
seq
#
echo -e "\e[31m ====================== \e[0m"
echo -e "\e[31m Top 20 Linux processes \e[0m"
echo -e "\e[31m ====================== \e[0m"
top -b -n 1|head -n 20
e="
PID    - 进程ID
USER   - 跑在哪个用户名下面
PR     - 优先级-20最高 19最低
NI     - Nice value  
VIRT   - 虚拟内存用量
RES    - 驻留集大小 Resident size (kb)
SHR    - 共享内存大小 (kb)  
S      - Process status - Possible values:
        R - Running
        D - Sleeping (may not be interrupted)
        S - Sleeping (may be interrupted)
        T - Traced or stopped
        Z - Zombie or \"hung\" process
%CPU    - CPU时间
%MEM    - 内存用量
TIME+   - 总共CPU使用量
COMMAND - 拉起进程的命令"
explain "$e"
