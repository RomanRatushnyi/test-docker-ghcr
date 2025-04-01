FROM alpine:latest
RUN echo "Hello, GitHub Container Registry!" > /hello.txt
CMD ["cat", "/hello.txt"]