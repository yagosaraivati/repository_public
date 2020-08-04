#QUAL O TIPO DA IMAGEN
FROM centos:7

#ATUALIZANDO REPOSITORIOS E INSTALANDO ATUALIZAÇÕES
RUN yum update -y

#INSTALANDO A FERRAMENTAS
RUN yum install -y \
wget \
curl \
git \
nano \
net-tools \
firewalld \
gunzip \
unzip

#LIMPANDO REPOSITORIOS QUE NÃO TEM MAIS USO
RUN yum autoremove -y

#MUDANDO O PADRAO LANG
RUN echo '"LANG="pt_BR.ISO-8859-1" \
SUPPORTED="pt_BR.ISO-8859-1:pt_BR:pt" \
SYSFONT="latarcyrheb-sun16"' > /etc/locale.conf 

#CRIANDO USUARIO MGEWEB
RUN useradd mgeweb

#ADICIONAR LIMITS AO USUARIO MGEWEB
RUN echo "mgeweb soft nofile 1024 \
mgeweb hard nofile 65536 \
mgeweb soft nproc 2047 \
mgeweb hard nproc 16384 \
mgeweb soft stack 10240 \
mgeweb hard stack 32768" >> /etc/security/limits.conf

#TROCANDO PARA USUARIO MGEWEB PARA INSTALAR O JDK (JAVA)
USER mgeweb
WORKDIR /home/mgeweb

#DOWNLOAD DO WILDFLY - GERENCIADOR DE PACOTES - APP SANKHYA - JAVA 8u231
RUN wget https://downloads-sankhya-jdk.s3-sa-east-1.amazonaws.com/jdk-8u231-linux-x64.tar.gz \
    && wget http://downloads.sankhya.com.br/repositorio/wildfly \
    && wget https://downloads-sankhya-pkgmgr.s3.amazonaws.com/pkgmgr_snk_unix_x64_2_3b78.tar.gz \ 
    && wget https://downloads-sankhya-pkgs.s3.amazonaws.com/sankhya-w_3.31b525.pkg

#INSTALANDO O JDK (JAVA)
RUN tar xzf jdk-8u231-linux-x64.tar.gz

#DESCOMPACTANDO O GERENCIADO DE PACOTE E SANKHYA WILDFLY
RUN unzip wildfly
RUN tar -xzvf pkgmgr_snk_unix_x64_2_3b78.tar.gz

#CRIANDO UM ALIAS NO .BASH_PROFILE
RUN alias rmltwprod='rm -rf /home/mgeweb/wildfly_producao/standalone/log/home/mgeweb/wildfly_producao/standalone/tmp /home/mgeweb/wildfly_producao/standalone/work'
RUN alias jb_startprod=' killprod; rmltwprod; nohup /home/mgeweb/wildfly_producao/bin/standalone.sh -bmanagement 0.0.0.0 &'
RUN alias jb_logprod='tail -f /home/mgeweb/wildfly_producao/standalone/log/server.log'
RUN alias jb_psprod='ps ax | grep wildfly_producao'
RUN alias killprod='ps -ef | awk /wildfly_producao/ && !/awk/ {print \$2} | xargs kill -9 2>> /dev/null'
RUN alias pkg='/home/mgeweb/sankhyaW_gerenciador_de_pacotes/bin/./sankhyaw-package-manager'

#MOVENDO O ARQUIVO DA APP SANKHYA PARA O DIRETORIO DO GERENCIADOR DE PACOTES
RUN mv sankhya-w_3.31b525.pkg sankhyaW_gerenciador_de_pacotes/pkgs/

#CRIANDO A VARIAVEL DO JAVA
RUN ln -s $HOME/jdk1.8.0_231 $HOME/jdk8
ENV JAVA_HOME /home/mgeweb/jdk8/bin
ENV USER mgeweb

#LIMPEZA DE DOWNLOADS
RUN rm -rf pkgmgr_snk_unix_x64_2_3b78.tar.gz jdk-8u231-linux-x64.tar.gz wildfly

#EXPONDO NA PORTA
EXPOSE 8080

#INICIANDO AUTOMATICAMENTE
CMD ["/home/mgeweb/wildfly_producao/bin/standalone.sh","/bin/bash","-b","0.0.0.0"]