FROM ubuntu:14.04

RUN mkdir /work/aishack/ -p
RUN cd /work/aishack
COPY aishack/ /work/aishack/aishack
COPY templates/ /work/aishack/templates
COPY categories/ /work/aishack/categories
COPY tracks/ /work/aishack/tracks/
COPY tutorials/ /work/aishack/tutorials
COPY writers/ /work/aishack/writers
COPY aishack_uwsgi.ini /work/aishack/

# Install dependencies
RUN echo "Setting up machine"
RUN apt-get update
RUN apt-get upgrade -y

RUN echo "Installing requirements"
RUN apt-get install -y python
RUN apt-get install -y python-pip
RUN apt-get install -y python-dev
RUN apt-get install -y libjpeg-dev
RUN apt-get install -y libz-dev
RUN apt-get install -y wget
RUN apt-get install -y vim
RUN apt-get install -y nginx

COPY requirements.txt /work/aishack/
RUN pip install -r /work/aishack/requirements.txt
RUN pip install uwsgi

# Run migrations
COPY manage.py /work/aishack/
RUN cd /work/aishack && python manage.py migrate

# Setup supervisord
RUN apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Setup nginx
COPY nginx.conf /etc/nginx/sites-available/aishack.conf
RUN cd /etc/nginx/sites-enabled && ln -s /etc/nginx/sites-available/aishack.conf

COPY nginx.conf /etc/nginx/nginx.conf
COPY uwsgi_params /work/aishack/

RUN apt-get install -y redis-server
COPY name-that-dataset/ /work/aishack/name-that-dataset/

# Copy the custom Markdown extensions
# TODO No pip packages exist for this. Fix this when they do!
COPY 3rdparty/markdown/extensions/mdx_grid_table.py /usr/local/lib/python2.7/dist-packages/markdown/extensions
COPY 3rdparty/markdown/extensions/mdx_custom_span_class.py /usr/local/lib/python2.7/dist-packages/markdown/extensions
COPY 3rdparty/markdown/extensions/captions.py /usr/local/lib/python2.7/dist-packages/markdown/extensions

# Ingest content into the database!
RUN cd /work/aishack/ && python manage.py ingest_category categories/*
RUN cd /work/aishack/ && python manage.py ingest_user writers/*
RUN cd /work/aishack/ && python manage.py ingesttrack tracks/*
RUN cd /work/aishack/ && python manage.py ingesttutorial tutorials/*

CMD supervisord -n

# Weather port
EXPOSE 8000
