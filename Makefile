up:
	docker start sandbox-nginx || true
	nohup ./platform/cleanup_daemon.sh &
	python3 monitor/poller.py &
	python3 platform/api.py

down:
	docker stop sandbox-nginx

create:
	@read -p "Name: " name; \
	read -p "TTL: " ttl; \
	./platform/create_env.sh $$name $$ttl

destroy:
	./platform/destroy_env.sh $(ENV)

logs:
	tail -f logs/$(ENV)/app.log

simulate:
	./platform/simulate_outage.sh --env $(ENV) --mode $(MODE)
