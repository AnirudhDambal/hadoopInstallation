Here’s a ready-to-use `README.md` file for your **single-node Hadoop setup** on Ubuntu (WSL or native):

---

### 📄 `README.md` — Running Apache Hadoop on Ubuntu (Single Node)

````markdown
# Apache Hadoop Single-Node Setup (Ubuntu / WSL2)

This guide helps you start and manage a single-node Apache Hadoop cluster installed on Ubuntu (including WSL2).

---

## 📦 Requirements

- Ubuntu 20.04+ or WSL2 (Windows Subsystem for Linux)
- Java (OpenJDK 11)
- Hadoop (3.3.6 recommended)

---

## 🔧 Environment Variables (Add to `~/.bashrc` or `~/.profile`)

```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/home/hadoopuser/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
````

Reload with:

```bash
source ~/.bashrc
```

---

## 🔐 Setup SSH (One-time)

```bash
ssh-keygen -t rsa -P ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
ssh localhost
```

---

## ⚙️ Configure Hadoop

Edit the following config files inside `$HADOOP_HOME/etc/hadoop`:

### core-site.xml

```xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
```

### hdfs-site.xml

```xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
</configuration>
```

### mapred-site.xml (create if missing)

```xml
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
</configuration>
```

### yarn-site.xml

```xml
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
</configuration>
```

### hadoop-env.sh

Make sure this line is **uncommented and correct**:

```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

---

## 🧹 Format NameNode (Run once)

```bash
hdfs namenode -format
```

---

## ▶️ Start Hadoop

```bash
start-dfs.sh
start-yarn.sh
```

---

## ✅ Check Running Services

```bash
jps
```

Expected:

* NameNode
* DataNode
* SecondaryNameNode
* ResourceManager
* NodeManager

---

## 🌐 Web UIs

| Service                 | URL                                            |
| ----------------------- | ---------------------------------------------- |
| HDFS NameNode UI        | [http://localhost:9870](http://localhost:9870) |
| YARN ResourceManager UI | [http://localhost:8088](http://localhost:8088) |

---

## 🧪 Run Example Job (Pi Estimation)

```bash
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 4 1000
```

---

## 🛑 Stop Hadoop

```bash
stop-yarn.sh
stop-dfs.sh
```

---

## 📌 Notes

* All config paths assume Hadoop is extracted in: `/home/hadoopuser/hadoop`
* Replace `hadoopuser` with your username if different.
* Works perfectly with WSL2 on Windows.

---

## 🧠 Author

Anirudh Dambal — [GitHub](https://github.com/AnirudhDambal)
