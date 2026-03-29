FROM haskell:9.4

RUN apt-get update && apt-get install -y python3

WORKDIR /app

COPY . .

RUN cabal update && cabal build

CMD bash -c "cabal run && cd web && python3 -m http.server 10000"
