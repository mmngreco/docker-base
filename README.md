# Docker base

Este proyecto es una prueba de concepto de desarrollo en docker. La idea
es tener un imagen docker común de la que partir y añadir las capas necesarias
que necesite cada proyecto.

Incluye

* vim
* freetds
* odbs
* python3.6
* pyenv

Es una imágen básica pero extensible.

## BUILD 

La idea es tener algo lo suficientemente flexible como para que cubra todas
las necesidades. Por ello el build requiere de las siguiente variables de 
entorno:


```docker
ARG SSH_PRIVATE_KEY
ARG SSH_PUBLIC_KEY
ARG APT_LIST
ARG CONFIG_INI
```

* `SSH_*_KEYS`: Esto permite que cada usuario pueda lanzar en local sin tener
  que distruibuir su clave ssh. La clave ssh es necesaria para descargar repos
  privados.
* `APT_LIST`: es una variable que permite añadir dependencias extra sin tener
  que modificar el `Dockerfile`.
* `CONFIG_INI`: Permite crear un `config.ini` en `ETS/configs/config.ini`.

Para hacer el build mas facil se incluye el fichero `docker_build.sh`.


IMPORTANTE: Una vez hecho el build, las claves se borran.

## RUN

Para poder incluir las claves ssh en la instancia `run` se han incluido 
una lógica en el `.bashrc` que basicamente crea las claves a partir de 
variables de entorno (las mismas que en el build).

Para hacer el run mas fácil se ha incluido el fichero `docker_run.sh`.

Se crea un volumen automaticamente del current working directory en `/ETS/git/`.
Esto permite lanzar el mismo script `docker_run.sh` desde cualquier directorio
y crea el volumen correspondiente a la carpeta en la que nos encontremos.

