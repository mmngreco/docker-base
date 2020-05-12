# Docker base

Este proyecto es una prueba de concepto de desarrollo en docker. La idea
es tener un imagen docker común de la que partir y añadir las capas necesarias
que necesite cada proyecto.

## Incluye

* git
* wget
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

## Example

Estoy trabajando en `boa` y quiero comprobar que todo funciona correctamente,
sin crearme un entorno en mi maquina y demas.

```bash
boa ❯ cd boa/
boa ❯ bash /home/mgreco/gitlab/com/docker-base/docker_run.sh

CONTAINER_NAME: base-df0748d
*** CONTAINER_LOG_LEVEL = 3 (info)
*** Set environment for startup files
*** Set environment for container process
*** Running /bin/bash...
root@eff58a185717:/ETS/git# ls
boa
root@eff58a185717:/ETS/git# ls ~/.ssh/
id_rsa  id_rsa.pub  known_hosts
root@eff58a185717:/ETS/git# cd boa
root@eff58a185717:/ETS/git/boa# pip install -e .
Obtaining file:///ETS/git/boa
...
Installing collected packages: numpy, bottleneck, pyparsing, six, cycler, kiwisolver, python-dateutil, matplotlib, llvmlite, numba, numexpr, pytz, pandas, joblib, scipy, scikit-learn, boa
  Running setup.py install for bottleneck ... done
  Running setup.py develop for boa
Successfully installed boa bottleneck-1.3.2 cycler-0.10.0 joblib-0.14.1 kiwisolver-1.2.0 llvmlite-0.32.1 matplotlib-3.2.1 numba-0.49.1 numexpr-2.7.1 numpy-1.18.4 pandas-1.0.3 pyparsing-2.4.7 python-dateutil-2.8.1 pytz-2020.1 scikit-learn-0.22.2.post1 scipy-1.4.1 six-1.14.0
You are using pip version 18.1, however version 20.1 is available.
You should consider upgrading via the 'pip install --upgrade pip' command.
root@eff58a185717:/ETS/git/boa# python
Python 3.6.10 (default, May 12 2020, 10:50:13)
[GCC 5.4.0 20160609] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import boa
>>>
```
