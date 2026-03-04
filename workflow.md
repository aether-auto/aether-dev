# Claude Build Workflow

# Planning Phase

## Ideation
- Should be controlled by claude code command `\ideate`
- Expect a web app idea from the user from ranging levels of complexity and completion. 
- Repeatedly use the AskUserQuestionTool to get more information from the user about the idea. Focus on tech stack preferences, coding preferences, ui preferences, testing, ci/cd, vision, goals, and all other important information to create the spec.md file. 
- Using this information, the agent should create a spec.md file with a clearly defined structure and proper sectioning. Some examples of important sections should be user stories, api specs, data models, ui flows pages and screens, auth, etc.
- A Claude code hook should be used to validate the spec.md file at the end of the ideation phase.
- Information about the "interview" and planning phase should be added as skills to be referred.

## Setup
- Controlled by claude code command `\setup`
- Using project information in spec.md, an agent should create project level CLAUDE.md setup and other necessary docs linked to CLAUDE.md. These docs can inlcude, full data models and api specs, product goals, common commands, ui vision, code styling, user flows, etc.
- Create a skill to guide agents to provide consistent and great quality output context

## Generate Tasks
- Controlled by claude code command `\gen-tasks`
- Using all project context created, the agent should create a list of todo tasks for the project end to end. This should not include setup and based on the description below you should see what things you should include here. Feature-based todos, or more full-stack todos would be preferred. Each todo should have a summary, a detailed description of what needs to be done, an actionable checklist to determine completion, and dependencies. 
- Todos should be created in a parseable, readable format.
- Todos should be in a folder called `.tasks`. There should be an INDEX file in the folder listing every todo and its info in a table with links to the files. At the top should be a list of all currently unblocked tickets updated every time a task is marked completed.
- Task formatting should be validated with hooks
- A skill should be created providing information on how this should be done 

## UI Specs 
- Controlled by claude code command `\ui-specs`
- A iterative conversation for UI specs for the project. 
- Agent should use official Anthropic frontend-design skill to create single file HTML/CSS specs for all UI pages using the design and ui vision of the project as outlined in the docs.
- It should also create a page where the user would be able to view all the specs together along with some design choices displayed and easily editable like font, or colors. 
- It should serve this on a local server for the user to view, approve and provide recommendations to

## Scaffolding
- Controlled by claude code command `\scaffold`
- This is project file setup step. You need to initialize the git repository, create initial project infrastructure, initial testing infrastructure, initial db infrastructure and also setup the ci/cd architecture.
- I want skills for every part of the setup to be referred to as and when it is being setup. This assures consistency accross all projects with better quality output.

# Building Phase (Per Task)

## Build
- Controlled by claude code command `\build`
- Should pick up the next viable ticket on the queue to work on it. An important thing to remember is that we are going to use agent teams and test-driven development.
- The team lead should first start with a product manager and testing agent each with individual skills. They need to define the set of goals or the intended behavior of the ticket to write tests for. Tests can include fast unit tests or proper integration tests. Tests should initially be failing. 
- Then different agents for coding tasks should be spawned, like for frontend, backend, db, data, etc. These should work with the PM and testing agent to keep tests intact while building up the codebase to pass the tests.
- Finally, there should be a QA agent optionally launched to use the Playwright mcp to test UI changes locally in the browser and API changes direcly by sending requests.
- Lastly there should be a refactoring and code quality agent performing code simplification, modularization and refactoring. 
- Each agent should have their own unique skill including individual skills for all posisble coding agents like a frontend (you can use official Anthropic), backend, db, etc.
- Strong validation and formatting hooks deployed at write stages to ensure code quality and consistency.
- Ends with a commit

## Review
- Controlled by claude code command `\review`
- Performs a code review of the previous commit in the worktree but using completely fresh context (maybe using team agents)
- Should have a skill
- Should have hooks ensuring passing tests I suppose
- Should end in a push

# Project Memory and Management

## Rules
- There should be claude rules for all different languages and clear coding standards for quality and structure defined in them.
- In every step, the agent should look out for reusable, and clear instructions provided by the user and save it in a rule or create a new rule if necessary appropriately scoped.

## Local Claude.md
- For every new subdirectory created, the agent must create the subdirectory's CLAUDE.md file with information about the folder, specific commands, tips, user rules, etc to be updated and maintained.

## .agent-docs
- Bulk of agent generated reference material and docs for anything should be here. The agents should inherently be verbose about what theyre doing, should want to document everything for posterity and consistency.

# Unknowns

- Adding Monitoring into the mix where the agents concurrently work on adding dev monitoring features while working on tasks.
- Exact Review architecture