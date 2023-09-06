FROM ubuntu:jammy-20230804

# STEP: verilator
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git perl python3 make autoconf g++ flex bison ccache libgoogle-perftools-dev numactl perl-doc libfl2 libfl-dev zlib1g zlib1g-dev
RUN git clone -b v4.224 https://github.com/verilator/verilator && cd verilator && \
    unset VERILATOR_ROOT && autoconf && ./configure && make -j4 && make install && \
    cd .. && rm -rf verilator




# STEP: python3
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    python3 \
    python3-pip && \
    python3 -m pip install numpy==1.24.2 matplotlib==3.7.1

