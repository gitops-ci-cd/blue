FROM ruby:2-slim

LABEL "name"="Feature Overlay Action"
LABEL "maintainer"="Brett Dudo <brett@dudo.io>"
LABEL "version"="0.0.0"

LABEL "com.github.actions.icon"="git-commit"
LABEL "com.github.actions.color"="orange"
LABEL "com.github.actions.name"="Feature Overlay"
LABEL "com.github.actions.description"="This creates a namespace for a feature and ensures your services are still connected"
# COPY LICENSE README.md THIRD_PARTY_NOTICE.md /

COPY Gemfile Gemfile.lock cleanup.rb creation.rb ./
COPY templates ./templates

RUN bundle install --without=development test

COPY feature_overlay.rb /bin/feature_overlay
RUN ["chmod", "+x", "/bin/feature_overlay"]

ENTRYPOINT ["feature_overlay"]
CMD ["help"]