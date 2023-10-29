# eldewrito-server

Inspired by https://github.com/DomiStyle/docker-eldewrito

Place an eldewrito directory at `eldewrito-game` and run `./build` to build the image.

Once the image is build you can run `copy-to-k3s` to copy the image to a k3s cluster for use with the helm chart provided at `./helm/eldewrito-server`.