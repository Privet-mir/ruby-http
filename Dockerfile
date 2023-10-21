FROM alpine:3.15.0

RUN apk update && apk upgrade && apk add bash && apk add curl

RUN apk add ruby

RUN rm -rf /var/cache/apk/*

#Creating a user by name mohammed
RUN adduser -D mohammed
#Setting the user
USER mohammed

WORKDIR /usr/src/app/

COPY --chown=mohammed . ./

EXPOSE 80
#When setting the CMD instruction, prefer the exec format over the shell format
CMD ["ruby", "./http_server.rb"]
