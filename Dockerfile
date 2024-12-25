FROM node:16
RUN npm install -g @vercel/cli firebase-tools gh
CMD ["/bin/bash"]
