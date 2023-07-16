# FROM elixir:1.13.4-otp-25
FROM elixir:1.14.2 

ARG mix_env=prod
ENV MIX_ENV $mix_env
ENV OPEN_AI_KEY $OPEN_AI_KEY
ENV SCREENSHOT_API_KEY $SCREENSHOT_API_KEY

# 
RUN mkdir /app
WORKDIR /app

EXPOSE 4000
EXPOSE 4001

ADD . /app
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install hex phx_new 1.4.1 
RUN mix deps.get
RUN mix deps.update gettext

RUN mix compile 
 

CMD ["sh", "./run.sh"]
