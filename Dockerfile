#QUAL O TIPO DA IMAGEN
FROM centos:7

#CRIADOR DA IMAGEN
MAINTAINER aulacursoyams@gmail.com

#PARAMETROS QUE SERA USADO PARA CRIAR A IMAGEN
RUN yum update -y
RUN yum upgrade -y
RUN yum install -y wget
RUN yum autoremove -y
RUN wget https://downloads-sankhya-pkgs.s3.amazonaws.com/sankhya-w_4.0b480.pkg

#DESCRICAO DA IMAGEN
LABEL Description="SankhyaOM"
