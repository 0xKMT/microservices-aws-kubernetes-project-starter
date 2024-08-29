FROM python:3.10-slim-buster


# Update the local package index with the latest packages from the repositories
RUN apt update -y

# Install a couple of packages to successfully install postgresql server locally
RUN apt install build-essential libpq-dev -y

# Update python modules to successfully build the required modules
# RUN pip install --upgrade pip setuptools wheel

# Install app dependencies
COPY analytics/ ./app
## Create app directory
WORKDIR /app

RUN pip install -r requirements.txt

EXPOSE 5153
CMD [ "python", "./app.py" ]