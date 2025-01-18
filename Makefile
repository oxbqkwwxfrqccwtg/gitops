# Define the phony targets
#.PHONY: 

agent: agent-audit agent-build agent-test agent-release agent-doc agent-clean

agent-build:
	sh srv/target/build/gitops-agent
agent-test:
	sh srv/target/test/gitops-agent
agent-release:
	sh srv/target/release/gitops-agent
agent-doc:
	sh srv/target/doc/gitops-agent
agent-clean:
	sh srv/target/clean/gitops-agent
agent-audit:
	sh srv/target/audit/gitops-agent
