#/bin/bash

DOCKER_IMAGE_REPO="lucasheld/newsleecher"

run_build() {
    STAGE=$1  # final or beta

    echo "Building $STAGE docker image..."
    if [ "$STAGE" = "final" ]
    then
        URL="https://www.newsleecher.com/nl_setup.exe"
    fi
    if [ "$STAGE" = "beta" ]
    then
        URL="https://www.newsleecher.com/nl_setup_beta.exe"
    fi
    docker build \
        --no-cache \
        --pull \
        --build-arg NEWSLEECHER_URL=$URL \
        -t $DOCKER_IMAGE_REPO .

    echo "Creating docker image tags..."
    if [ "$STAGE" = "final" ]
    then
        TAGS=("latest" "final" "$FINAL_VERSION")
    fi
    if [ "$STAGE" = "beta" ]
    then
        TAGS=("beta" "$BETA_VERSION")
    fi
    for TAG in ${TAGS[@]}
    do
        docker tag $DOCKER_IMAGE_REPO $DOCKER_IMAGE_REPO:$TAG
    done

    echo "Logging in to docker hub..."
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

    echo "Pushing docker image tags..."
    for TAG in ${TAGS[@]}
    do
        docker push $DOCKER_IMAGE_REPO:$TAG
    done

    docker logout
    echo "Build $STAGE done"
}

# get current newsleecher versions
RESPONSE_NL_VERSIONS=$(curl -s 'https://www.newsleecher.com/internal/internal_loader.v2.php?prodID=nl&prodVer=80004')
FINAL_VERSION_RAW=$(echo $RESPONSE_NL_VERSIONS | grep -oP "(?<=<latestfinal>)\d+(?=</latestfinal>)")
BETA_VERSION_RAW=$(echo $RESPONSE_NL_VERSIONS | grep -oP "(?<=<latestbeta>)\d+(?=</latestbeta>)")
echo "latest final raw: $FINAL_VERSION_RAW"
echo "latest beta raw: $BETA_VERSION_RAW"

# format versions
FINAL_VERSION="${FINAL_VERSION_RAW:0:1}.0"
BETA_VERSION="${BETA_VERSION_RAW:0:1}.0-beta.${BETA_VERSION_RAW: -1}"
echo "latest final: $FINAL_VERSION"
echo "latest beta: $BETA_VERSION"

# skip existing builds
RESPONSE_DOCKER_TAGS=$(curl -s -L https://index.docker.io/v1/repositories/${DOCKER_IMAGE_REPO}/tags)
# final
if echo $RESPONSE_DOCKER_TAGS | grep -E "\"${FINAL_VERSION}\""
then
    echo "Skipping final build: Docker image with tag $FINAL_VERSION already exists."
else
    run_build "final"
fi
# beta
if echo $RESPONSE_DOCKER_TAGS | grep -E "\"${BETA_VERSION}\""
then
    echo "Skipping beta build: Docker image with tag $BETA_VERSION already exists."
else
    run_build "beta"
fi
