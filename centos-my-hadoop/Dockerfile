#指定操作的镜像
FROM centos
#维护者信息
MAINTAINER henryshue 2019-04-09

#安装集群必须的ssh
RUN yum install -y openssh-server openssh-clients 
#安装iproute、vim、which等常用工具
RUN yum install -y iproute vim which 

#建立存放JDK的目录
RUN mkdir /usr/local/java
#将JDK复制到镜像，ADD指令会自动解压
ADD software/jdk-8u121-linux-x64.tar.gz /usr/local/java

#生成host key文件，否则/usr/sbin/sshd将无法启动
RUN ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' &&  ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' &&  ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N ''
#配置无密码登录到本机，首先生成公钥和私钥，再建立authorized_keys文件
RUN ssh-keygen -f /root/.ssh/id_rsa -N '' &&  cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

#将hadoop安装包拷贝到镜像中
ADD software/hadoop-2.7.2.tar.gz /usr/local
#建立软链接
RUN ln -s /usr/local/hadoop-2.7.2 /usr/local/hadoop

#更新配置文件
COPY config/hadoop/core-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/hadoop/hdfs-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/hadoop/mapred-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/hadoop/yarn-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/hadoop/slaves /usr/local/hadoop/etc/hadoop/

# 重新设置hadoop-env.sh中的JAVA_HOME变量
# 配置ssh_config文件中： StrictHostKeyChecking no， 可以消除ssh，scp等访问时询问yes/no。
# 配置sshd_config 文件中， UseDNS no ， UseDNS 的默认值为 yes。 配置为no之后可以加速ssh，scp链接速度。
RUN sed -i "s?JAVA_HOME=\${JAVA_HOME}?JAVA_HOME=/usr/local/java/jdk?g" /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
sed -i "s?#\s\+StrictHostKeyChecking\s\+ask?StrictHostKeyChecking no?g" /etc/ssh/ssh_config  && \
sed -i "s?#UseDNS yes?UseDNS no?g" /etc/ssh/sshd_config

# 这里配置镜像的环境变量，注意只能在运行时使用/bin/bash时才会生效。当用ssh登录到容器后，这些变量将失效
ENV JAVA_HOME /usr/local/java/jdk
ENV JRE_HOME ${JAVA_HOME}/jre
ENV CLASSPATH .:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH ${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${JAVA_HOME}/bin:$PATH
# 当用ssh登录到容器后，上述设置的变量将失效，为了能够在ssh登陆时也能使用这些变量，将其加入到root账户的.bash_profile文件中。
# 注意export JRE_HOME=/usr/local/java/jdk/jre 不能写成 export JRE_HOME=${JAVA_HOME}/jre。其它的也是同理，配置中都是从绝对路径写起
RUN ln -s /usr/local/java/jdk1.8.0_121 /usr/local/java/jdk && \
 echo "export JAVA_HOME=/usr/local/java/jdk" >> /root/.bash_profile && \
 echo "export JRE_HOME=/usr/local/java/jdk/jre" >> /root/.bash_profile && \
 echo "export CLASSPATH=.:/usr/local/java/jdk/lib:/usr/local/java/jdk/jre/lib" >> /root/.bash_profile && \
 echo "export HADOOP_HOME=/usr/local/hadoop" >> /root/.bash_profile && \
 echo "export PATH=/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/java/jdk/bin:$PATH" >> /root/.bash_profile

# 设置root账户的密码
RUN echo "root:030479" | chpasswd
# 设置容器启动时，默认要的执行的命令
CMD ["/usr/sbin/sshd","-D"]
