# Use a specific version of the Node.js image that matches your project's requirements
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of your application's code
COPY . .

# Build the application using the yarn scripts
RUN yarn build

# Expose the port your app runs on
EXPOSE 3000

# Command to run your app using yarn
CMD ["yarn", "start"]
