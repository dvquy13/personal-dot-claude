Think hard about how to implement the task in $ARGUMENTS, leverage the agents under .claude/agents when needed.

## Clarifying the task
If the task is not clear, ask human for clarification.

## Addressing COMMENTs
First find all mentions of COMMENT in the task, if there are any you should focus on them. DO REMEMBER that my COMMENTs are there for you to think ultra hard about it and do not be afraid to argue with me.

If you decide to update the task, you can just overwrite the input $ARGUMENTS file with your updated plan without comparing to the previous version, unless specifically asked to.

If no COMMENT is found, you should review the task and work on the implementation plan.

## Plan only, do not implement

You can create and run intermediate scripts to gather information, but DO NOT implement the main task.

If you're unsure about anything, please ask me for help, do not make assumptions.

If you propose options, you can pause and ask me for input about which option to proceed with.

## Keep the main task file updated

At the end, update the input $ARGUMENTS file with your plan which should include how to test/verify the implementation. 
You can rephrase the original task to make it clearer.

## Break complex tasks into milestones

If the task is complex, break it into smaller milestones. If the task is not complex you can skip this step and consider the whole task as one milestone.
When doing so, remember that we adopt incremental/progressive development approach, so break the task into milestones where each milestone is a self-contained and manageable chunk of work where we can test and verify.

Define deliverables for each milestone.

## Testing and Verification

When planning Testing and Verification, return up to 3 most important verifications that you can either automate with test scripts or need human to manually verify. This applies to each milestone.
