# Use the official Python slim image
FROM python:3.11-slim

# Install system dependencies including Tkinter, Xvfb, and X11 utilities
RUN apt update && apt install -y \
    git \
    tk \
    tcl \
    libx11-6 \
    libxrender-dev \
    libxext-dev \
    libxinerama-dev \
    libxi-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxtst-dev \
    tk-dev \
    xvfb \
    x11-apps \
    x11vnc \
    fluxbox \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /app

RUN     mkdir ~/.vnc
RUN     x11vnc -storepasswd 1234 ~/.vnc/passwd

COPY . .

ADD https://codeberg.org/attachments/147f41a3-a6ea-45f6-8c2a-25bac4495a1d /app/load_this_device_file.xml

RUN pip install --no-cache-dir \
    pyyaml \
    pyasn1==0.4.8 \
    git+https://github.com/etingof/pysnmp.git@master#egg=pysnmp \
    pyasyncore \
    tkcalendar \
    pyperclip \
    black \
    tomli \
    text-console

# Set the DISPLAY environment variable for Xvfb
ENV DISPLAY=:99

COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose the VNC port
EXPOSE 5990

# Set the entrypoint to automatically run the script
ENTRYPOINT ["/start.sh"]
