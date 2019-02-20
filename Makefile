# workstation runs the workstation through docker-compose
workstation:
	@docker-compose run \
		--rm \
		-e GOPATH=/src/go \
		-v /src:/src \
		workstation
.PHONY: workstation
