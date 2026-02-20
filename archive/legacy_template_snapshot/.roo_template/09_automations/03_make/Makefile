WO ?= WO-$(shell date +%Y%m%d)-001
SHORT ?= work

new-wo:
	bash ../01_scripts/01_new_work_order.sh $(WO) $(SHORT)

kickoff-wo:
	bash ../01_scripts/01_new_work_order.sh $(WO) $(SHORT)
	bash ../01_scripts/06_git_control_check.sh $(WO) branch

prepare-context:
	bash ../01_scripts/02_prepare_context.sh $(WO)

prepare-review:
	bash ../01_scripts/11_prepare_review.sh $(WO)

quality:
	bash ../01_scripts/03_run_quality.sh $(WO)

validate-quality:
	bash ../01_scripts/05_validate_wo.sh $(WO) quality

pack-delivery:
	bash ../01_scripts/04_pack_delivery.sh $(WO)

validate-delivery:
	bash ../01_scripts/05_validate_wo.sh $(WO) delivery

review-gate:
	bash ../01_scripts/12_review_gate.sh $(WO)

git-check-branch:
	bash ../01_scripts/06_git_control_check.sh $(WO) branch

git-check-commit:
	bash ../01_scripts/06_git_control_check.sh $(WO) commit

git-check-merge:
	bash ../01_scripts/06_git_control_check.sh $(WO) merge

review-artifacts:
	bash ../01_scripts/07_prepare_review_artifacts.sh $(WO) wo/$(WO)-$(SHORT)

install-hooks:
	bash ../01_scripts/08_install_git_hooks.sh

commit-work-order:
	bash ../01_scripts/09_git_commit_stage.sh $(WO) work-order

commit-context:
	bash ../01_scripts/09_git_commit_stage.sh $(WO) context

commit-implementation:
	bash ../01_scripts/09_git_commit_stage.sh $(WO) implementation

commit-quality:
	bash ../01_scripts/09_git_commit_stage.sh $(WO) quality

commit-delivery:
	bash ../01_scripts/09_git_commit_stage.sh $(WO) delivery

commit-review:
	bash ../01_scripts/09_git_commit_stage.sh $(WO) review

merge-wo:
	bash ../01_scripts/10_git_merge_wo.sh $(WO) $(SHORT)
