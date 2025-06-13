document.addEventListener('DOMContentLoaded', () => {
    // Application State
    const state = {
        connected: { github: false, sonar: false },
        repositories: [],
        workflows: [{ id: 'workflow-1', name: 'Workflow 1', nodes: [], connections: [] }],
        currentWorkflowId: 'workflow-1',
        selectedNode: null,
        selectedNodes: new Set(),
        selectedConnection: null,
        githubRepos: [],
        sonarProjects: [],
        issues: [],
        healthScores: [],
        activities: [],
        githubLabels: [],
        zoomLevel: 1,
        canvasTransform: { x: 0, y: 0 }
    };

    // DOM Elements
    const elements = {
        githubConnect: document.getElementById('github-connect'),
        sonarConnect: document.getElementById('sonar-connect'),
        sonarToken: document.getElementById('sonar-token'),
        githubStatus: document.getElementById('github-status'),
        sonarStatus: document.getElementById('sonar-status'),
        connectionStatus: document.getElementById('connection-status'),
        addLinkBtn: document.getElementById('add-link-btn'),
        linkModal: document.getElementById('link-modal'),
        cancelLink: document.getElementById('cancel-link'),
        createLink: document.getElementById('create-link'),
        githubRepoSelect: document.getElementById('github-repo-select'),
        sonarProjectSelect: document.getElementById('sonar-project-select'),
        repoLinks: document.getElementById('repo-links'),
        workflowCanvas: document.getElementById('workflow-canvas'),
        connectorsSvg: document.getElementById('connectors'),
        nodeProperties: document.getElementById('node-properties'),
        closeProperties: document.getElementById('close-properties'),
        nodePropertiesContent: document.getElementById('node-properties-content'),
        workflowSelect: document.getElementById('workflow-select'),
        saveWorkflow: document.getElementById('save-workflow'),
        runWorkflow: document.getElementById('run-workflow'),
        runAllWorkflows: document.getElementById('run-all-workflows'),
        settingsBtn: document.getElementById('settings-btn'),
        settingsModal: document.getElementById('settings-modal'),
        closeSettings: document.getElementById('close-settings'),
        connectedRepos: document.getElementById('connected-repos'),
        activeIssues: document.getElementById('active-issues'),
        resolvedIssues: document.getElementById('resolved-issues'),
        recentActivity: document.getElementById('recent-activity'),
        issuesList: document.getElementById('issues-list'),
        healthScores: document.getElementById('health-scores'),
        quickActions: document.querySelectorAll('.quick-action'),
        addIssueBtn: document.getElementById('add-issue-btn'),
        addIssueModal: document.getElementById('add-issue-modal'),
        cancelIssue: document.getElementById('cancel-issue'),
        createIssue: document.getElementById('create-issue'),
        issueRepoSelect: document.getElementById('issue-repo-select'),
        issueTitle: document.getElementById('issue-title'),
        issueDescription: document.getElementById('issue-description'),
        issueColor: document.getElementById('issue-color'),
        zoomIn: document.getElementById('zoom-in'),
        zoomOut: document.getElementById('zoom-out'),
        resolutionTrendsChart: document.getElementById('resolution-trends-chart'),
        severityDistributionChart: document.getElementById('severity-distribution-chart')
    };

    // Charts
    let resolutionTrendsChart, severityDistributionChart;
    function initializeCharts() {
        // Destroy existing charts to prevent duplication
        if (resolutionTrendsChart) resolutionTrendsChart.destroy();
        if (severityDistributionChart) severityDistributionChart.destroy();

        // Ensure canvas containers have fixed dimensions
        const trendsContainer = elements.resolutionTrendsChart.parentElement;
        const severityContainer = elements.severityDistributionChart.parentElement;
        trendsContainer.style.height = '250px';
        severityContainer.style.height = '250px';
        elements.resolutionTrendsChart.style.maxHeight = '250px';
        elements.severityDistributionChart.style.maxHeight = '250px';

        const trendsCtx = elements.resolutionTrendsChart.getContext('2d');
        resolutionTrendsChart = new Chart(trendsCtx, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [{
                    label: 'Issues Resolved',
                    data: [10, 15, 8, 20, 12, 18],
                    borderColor: '#3b82f6',
                    backgroundColor: 'rgba(59, 130, 246, 0.2)',
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: { beginAtZero: true }
                }
            }
        });

        const severityCtx = elements.severityDistributionChart.getContext('2d');
        severityDistributionChart = new Chart(severityCtx, {
            type: 'pie',
            data: {
                labels: ['Critical', 'Major', 'Minor'],
                datasets: [{
                    data: [30, 50, 20],
                    backgroundColor: ['#ef4444', '#f59e0b', '#3b82f6']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false
            }
        });
    }

    // Tab Management
    document.querySelectorAll('.tab-btn').forEach(button => {
        button.addEventListener('click', () => {
            const targetTab = button.getAttribute('data-tab');
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.classList.remove('active', 'border-blue-500', 'text-blue-400');
                btn.classList.add('border-transparent', 'text-gray-400');
            });
            button.classList.add('active', 'border-blue-500', 'text-blue-400');
            document.querySelectorAll('.tab-content').forEach(content => content.classList.add('hidden'));
            document.getElementById(`${targetTab}-tab`).classList.remove('hidden');
            if (targetTab === 'analytics') initializeCharts();
        });
    });

    // Connection Management
    elements.githubConnect.addEventListener('click', () => {
        if (!state.connected.github) {
            elements.githubConnect.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>Connecting...';
            elements.githubConnect.disabled = true;
            setTimeout(() => {
                state.connected.github = true;
                state.githubRepos = [
                    { name: 'my-awesome-project', owner: 'user' },
                    { name: 'backend-service', owner: 'user' },
                    { name: 'frontend-app', owner: 'user' }
                ];
                elements.githubStatus.classList.replace('bg-red-500', 'bg-green-500');
                elements.githubConnect.innerHTML = '<i class="fas fa-check mr-2"></i>Connected';
                elements.githubConnect.classList.replace('bg-blue-600', 'bg-green-600');
                elements.githubConnect.disabled = false;
                updateConnectionStatus();
                updateRepoSelects();
                addActivity('GitHub connected', 'fas fa-code-branch', 'text-blue-400');
            }, 1000);
        } else {
            state.connected.github = false;
            state.githubRepos = [];
            elements.githubStatus.classList.replace('bg-green-500', 'bg-red-500');
            elements.githubConnect.innerHTML = 'Connect to GitHub';
            elements.githubConnect.classList.replace('bg-green-600', 'bg-blue-600');
            updateConnectionStatus();
            updateRepoSelects();
            addActivity('GitHub disconnected', 'fas fa-code-branch', 'text-red-400');
        }
    });

    elements.sonarConnect.addEventListener('click', () => {
        if (!elements.sonarToken.value.trim()) {
            alert('Please enter a SonarQube token');
            return;
        }
        if (!state.connected.sonar) {
            elements.sonarConnect.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>Connecting...';
            elements.sonarConnect.disabled = true;
            setTimeout(() => {
                state.connected.sonar = true;
                state.sonarProjects = [
                    { key: 'my-awesome-project', name: 'My Awesome Project' },
                    { key: 'backend-service', name: 'Backend Service' },
                    { key: 'frontend-app', name: 'Frontend App' }
                ];
                elements.sonarStatus.classList.replace('bg-red-500', 'bg-green-500');
                elements.sonarConnect.innerHTML = '<i class="fas fa-check mr-2"></i>Connected';
                elements.sonarConnect.classList.replace('bg-orange-600', 'bg-green-600');
                elements.sonarConnect.disabled = false;
                updateConnectionStatus();
                updateRepoSelects();
                addActivity('SonarQube connected', 'fas fa-shield-alt', 'text-orange-400');
            }, 1000);
        } else {
            state.connected.sonar = false;
            state.sonarProjects = [];
            elements.sonarStatus.classList.replace('bg-green-500', 'bg-red-500');
            elements.sonarConnect.innerHTML = 'Connect to SonarQube';
            elements.sonarConnect.classList.replace('bg-green-600', 'bg-orange-600');
            updateConnectionStatus();
            updateRepoSelects();
            addActivity('SonarQube disconnected', 'fas fa-shield-alt', 'text-red-400');
        }
    });

    function updateConnectionStatus() {
        const { github, sonar } = state.connected;
        const statusDot = elements.connectionStatus.querySelector('div');
        const statusText = elements.connectionStatus.querySelector('span');
        if (github && sonar) {
            statusDot.classList.replace('bg-red-500', 'bg-green-500');
            statusDot.classList.replace('bg-yellow-500', 'bg-green-500');
            statusDot.classList.remove('animate-pulse');
            statusText.textContent = 'Connected';
        } else if (github || sonar) {
            statusDot.classList.replace('bg-red-500', 'bg-yellow-500');
            statusDot.classList.replace('bg-green-500', 'bg-yellow-500');
            statusDot.classList.add('animate-pulse');
            statusText.textContent = 'Partially Connected';
        } else {
            statusDot.classList.replace('bg-green-500', 'bg-red-500');
            statusDot.classList.replace('bg-yellow-500', 'bg-red-500');
            statusDot.classList.add('animate-pulse');
            statusText.textContent = 'Disconnected';
        }
    }

    function updateRepoSelects() {
        elements.githubRepoSelect.innerHTML = '<option value="">Select GitHub repository...</option>';
        elements.sonarProjectSelect.innerHTML = '<option value="">Select SonarQube project...</option>';
        elements.issueRepoSelect.innerHTML = '<option value="">Select repository...</option>';
        state.githubRepos.forEach(repo => {
            const option = document.createElement('option');
            option.value = `${repo.owner}/${repo.name}`;
            option.textContent = `${repo.owner}/${repo.name}`;
            elements.githubRepoSelect.appendChild(option);
            const issueOption = document.createElement('option');
            issueOption.value = `${repo.owner}/${repo.name}`;
            issueOption.textContent = `${repo.owner}/${repo.name}`;
            elements.issueRepoSelect.appendChild(issueOption);
        });
        state.sonarProjects.forEach(project => {
            const option = document.createElement('option');
            option.value = project.key;
            option.textContent = project.name;
            elements.sonarProjectSelect.appendChild(option);
        });
    }

    // Repository Linking
    elements.addLinkBtn.addEventListener('click', () => {
        if (!state.connected.github || !state.connected.sonar) {
            alert('Please connect to both GitHub and SonarQube first');
            return;
        }
        elements.linkModal.classList.remove('hidden');
    });

    elements.cancelLink.addEventListener('click', () => elements.linkModal.classList.add('hidden'));

    elements.createLink.addEventListener('click', () => {
        const githubRepo = elements.githubRepoSelect.value;
        const sonarProject = elements.sonarProjectSelect.value;
        if (!githubRepo || !sonarProject) {
            alert('Please select both repositories');
            return;
        }
        state.repositories.push({ github: githubRepo, sonar: sonarProject });
        elements.connectedRepos.textContent = state.repositories.length;
        renderRepoLinks();
        elements.linkModal.classList.add('hidden');
        addActivity(`Linked ${githubRepo} to ${sonarProject}`, 'fas fa-link', 'text-green-400');
        updateIssues();
        updateHealthScores();
    });

    function renderRepoLinks() {
        elements.repoLinks.innerHTML = '';
        state.repositories.forEach(repo => {
            const linkElement = document.createElement('div');
            linkElement.className = 'bg-gray-700 p-4 rounded-lg';
            linkElement.innerHTML = `
                <div class="flex items-center justify-between mb-2">
                    <div class="flex items-center space-x-2">
                        <i class="fas fa-link text-green-400"></i>
                        <span class="font-medium text-sm">${repo.github}</span>
                    </div>
                    <button class="remove-link text-red-400 hover:text-red-300" data-github="${repo.github}">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div class="flex items-center space-x-2 text-xs text-gray-400">
                    <i class="fas fa-arrow-down"></i>
                    <span>${repo.sonar}</span>
                </div>
                <div class="mt-3 flex space-x-2">
                    <button class="create-workflow bg-purple-600 hover:bg-purple-700 px-3 py-1 rounded text-xs transition-colors" data-github="${repo.github}">
                        Create Workflow
                    </button>
                    <button class="sync-issues bg-blue-600 hover:bg-blue-700 px-3 py-1 rounded text-xs transition-colors" data-github="${repo.github}">
                        Sync Issues
                    </button>
                </div>
            `;
            elements.repoLinks.appendChild(linkElement);
        });
        document.querySelectorAll('.remove-link').forEach(btn => {
            btn.addEventListener('click', () => {
                const githubRepo = btn.dataset.github;
                state.repositories = state.repositories.filter(r => r.github !== githubRepo);
                elements.connectedRepos.textContent = state.repositories.length;
                renderRepoLinks();
                addActivity(`Unlinked ${githubRepo}`, 'fas fa-unlink', 'text-red-400');
                updateIssues();
                updateHealthScores();
            });
        });
        document.querySelectorAll('.create-workflow').forEach(btn => {
            btn.addEventListener('click', () => {
                const githubRepo = btn.dataset.github;
                createNewWorkflow(`Workflow for ${githubRepo}`);
                document.querySelector('.tab-btn[data-tab="workflows"]').click();
            });
        });
        document.querySelectorAll('.sync-issues').forEach(btn => {
            btn.addEventListener('click', () => {
                addActivity('Issues synced', 'fas fa-sync', 'text-blue-400');
                updateIssues();
            });
        });
    }

    // Quick Actions
    elements.quickActions.forEach(btn => {
        btn.addEventListener('click', () => {
            const action = btn.dataset.action;
            const actions = {
                'sync-issues': () => {
                    addActivity('All issues synced', 'fas fa-sync', 'text-purple-400');
                    updateIssues();
                },
                'generate-report': () => addActivity('Report generated', 'fas fa-chart-bar', 'text-indigo-400'),
                'auto-link': () => addActivity('Issues auto-linked', 'fas fa-robot', 'text-teal-400'),
                'bulk-close': () => {
                    state.issues = state.issues.map(issue => ({ ...issue, status: 'closed' }));
                    addActivity('Issues bulk closed', 'fas fa-check-double', 'text-pink-400');
                    updateIssues();
                },
                'export-data': () => addActivity('Data exported', 'fas fa-download', 'text-yellow-400')
            };
            actions[action]();
        });
    });

    // Add Issue
    elements.addIssueBtn.addEventListener('click', () => {
        elements.addIssueModal.classList.remove('hidden');
    });

    elements.cancelIssue.addEventListener('click', () => {
        elements.addIssueModal.classList.add('hidden');
        elements.issueTitle.value = '';
        elements.issueDescription.value = '';
        elements.issueColor.value = '#000000';
    });

    elements.createIssue.addEventListener('click', () => {
        const repo = elements.issueRepoSelect.value;
        const title = elements.issueTitle.value.trim();
        const description = elements.issueDescription.value.trim();
        const color = elements.issueColor.value;
        if (!repo || !title) {
            alert('Please select a repository and enter a title');
            return;
        }
        const issueId = `issue-${state.issues.length + 1}`;
        state.issues.push({
            id: issueId,
            repo,
            severity: 'Minor',
            title,
            description,
            status: 'open',
            labelColor: color,
            assignee: null
        });
        updateIssues();
        elements.addIssueModal.classList.add('hidden');
        elements.issueTitle.value = '';
        elements.issueDescription.value = '';
        elements.issueColor.value = '#000000';
        addActivity(`Created issue: ${title}`, 'fas fa-plus-circle', 'text-blue-400');
    });

    // Workflow Management
    let nodeCounter = 0;
    let isConnecting = false;
    let startNodeId = null;
    let isDraggingConnection = false;
    let connectionStart = null;

    function createNewWorkflow(name) {
        const id = `workflow-${state.workflows.length + 1}`;
        state.workflows.push({ id, name, nodes: [], connections: [] });
        state.currentWorkflowId = id;
        updateWorkflowSelect();
        clearCanvas();
        addActivity(`Created workflow: ${name}`, 'fas fa-plus', 'text-blue-400');
    }

    function updateWorkflowSelect() {
        elements.workflowSelect.innerHTML = '<option value="new">New Workflow</option>';
        state.workflows.forEach(wf => {
            const option = document.createElement('option');
            option.value = wf.id;
            option.textContent = wf.name;
            elements.workflowSelect.appendChild(option);
        });
        elements.workflowSelect.value = state.currentWorkflowId;
    }

    elements.workflowSelect.addEventListener('change', () => {
        if (elements.workflowSelect.value === 'new') {
            createNewWorkflow(`Workflow ${state.workflows.length + 1}`);
        } else {
            state.currentWorkflowId = elements.workflowSelect.value;
            state.selectedNodes.clear();
            renderWorkflow();
        }
    });

    // Zoom Functionality
    elements.zoomIn.addEventListener('click', () => {
        state.zoomLevel = Math.min(state.zoomLevel + 0.1, 2);
        updateCanvasTransform();
    });

    elements.zoomOut.addEventListener('click', () => {
        state.zoomLevel = Math.max(state.zoomLevel - 0.1, 0.5);
        updateCanvasTransform();
    });

    elements.workflowCanvas.addEventListener('wheel', e => {
        e.preventDefault();
        const delta = e.deltaY < 0 ? 0.1 : -0.1;
        state.zoomLevel = Math.max(0.5, Math.min(state.zoomLevel + delta, 2));
        updateCanvasTransform();
    });

    function updateCanvasTransform() {
        elements.workflowCanvas.style.transform = `scale(${state.zoomLevel}) translate(${state.canvasTransform.x}px, ${state.canvasTransform.y}px)`;
        renderConnections();
    }

    // Drag and Drop Nodes
    document.querySelectorAll('.workflow-node-template').forEach(template => {
        template.addEventListener('dragstart', e => {
            e.dataTransfer.setData('node-type', e.target.dataset.type);
        });
    });

    elements.workflowCanvas.addEventListener('dragover', e => e.preventDefault());
    elements.workflowCanvas.addEventListener('drop', e => {
        e.preventDefault();
        const nodeType = e.dataTransfer.getData('node-type');
        const rect = elements.workflowCanvas.getBoundingClientRect();
        const x = (e.clientX - rect.left - 100) / state.zoomLevel;
        const y = (e.clientY - rect.top - 50) / state.zoomLevel;
        createWorkflowNode(nodeType, x, y);
    });

    // Connection Dragging
    elements.workflowCanvas.addEventListener('mousedown', e => {
        if (e.target.classList.contains('output-connector')) {
            isDraggingConnection = true;
            startNodeId = e.target.dataset.nodeId;
            const rect = elements.workflowCanvas.getBoundingClientRect();
            connectionStart = {
                x: (e.clientX - rect.left) / state.zoomLevel,
                y: (e.clientY - rect.top) / state.zoomLevel
            };
            const tempPath = document.createElementNS('http://www.w3.org/2000/svg', 'path');
            tempPath.id = 'temp-connection';
            tempPath.setAttribute('stroke', '#3b82f6');
            tempPath.setAttribute('stroke-width', '2');
            tempPath.setAttribute('fill', 'none');
            elements.connectorsSvg.appendChild(tempPath);
            document.addEventListener('mousemove', dragConnection);
            document.addEventListener('mouseup', stopDragConnection);
        }
    });

    function dragConnection(e) {
        if (!isDraggingConnection) return;
        const rect = elements.workflowCanvas.getBoundingClientRect();
        const x2 = (e.clientX - rect.left) / state.zoomLevel;
        const y2 = (e.clientY - rect.top) / state.zoomLevel;
        const path = document.getElementById('temp-connection');
        path.setAttribute('d', `M${connectionStart.x},${connectionStart.y} C${connectionStart.x + 50},${connectionStart.y} ${x2 - 50},${y2} ${x2},${y2}`);
    }

    function stopDragConnection(e) {
        if (!isDraggingConnection) return;
        isDraggingConnection = false;
        document.removeEventListener('mousemove', dragConnection);
        document.removeEventListener('mouseup', stopDragConnection);
        const tempPath = document.getElementById('temp-connection');
        if (tempPath) tempPath.remove();
        const target = e.target.closest('.workflow-node') || e.target.closest('.input-connector');
        if (target) {
            const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
            let toNodeId = target.dataset.nodeId || target.id;
            if (startNodeId !== toNodeId) {
                const fromNode = workflow.nodes.find(n => n.id === startNodeId);
                const toNode = workflow.nodes.find(n => n.id === toNodeId);
                if (fromNode && toNode && fromNode.type !== 'notification') {
                    if (toNode.type === 'trigger') return; // Prevent connecting to trigger input
                    workflow.connections.push({ from: startNodeId, to: toNodeId, scenario: null });
                    renderConnections();
                    updateConnectionDots();
                }
            }
        }
        startNodeId = null;
        connectionStart = null;
    }

    // Connection Deletion
    document.addEventListener('keydown', e => {
        if (e.key === 'Delete' && state.selectedConnection !== null) {
            const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
            workflow.connections.splice(state.selectedConnection, 1);
            state.selectedConnection = null;
            renderConnections();
            updateConnectionDots();
            addActivity('Removed connection', 'fas fa-trash', 'text-red-400');
        }
    });

    function createWorkflowNode(type, x, y) {
        nodeCounter++;
        const nodeId = `node-${nodeCounter}`;
        const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
        const nodeConfig = getNodeConfig(type);
        const node = {
            id: nodeId,
            type,
            position: { x, y },
            properties: type === 'condition' ? { scenarios: [{ condition: '', output: '' }] } : {}
        };
        workflow.nodes.push(node);

        const nodeElement = document.createElement('div');
        nodeElement.className = 'workflow-node absolute bg-gray-800 border-2 border-gray-600 rounded-lg p-4 cursor-move select-none shadow-lg';
        nodeElement.id = nodeId;
        nodeElement.style.left = `${x}px`;
        nodeElement.style.top = `${y}px`;
        nodeElement.style.width = '200px';
        nodeElement.dataset.type = type;
        let outputConnectors = '';
        if (type === 'condition') {
            node.properties.scenarios.forEach((_, idx) => {
                outputConnectors += `<div class="output-connector w-3 h-3 bg-gray-500 rounded-full cursor-pointer" data-node-id="${nodeId}" data-scenario="${idx}"></div>`;
            });
        } else if (type !== 'notification') {
            outputConnectors = `<div class="output-connector w-3 h-3 bg-gray-500 rounded-full cursor-pointer" data-node-id="${nodeId}"></div>`;
        }
        nodeElement.innerHTML = `
            <div class="flex items-center justify-between mb-2">
                <div class="flex items-center space-x-2">
                    <i class="${nodeConfig.icon} ${nodeConfig.color}"></i>
                    <span class="font-medium text-sm">${nodeConfig.title}</span>
                </div>
                <div class="flex space-x-2">
                    ${type !== 'trigger' ? `<div class="input-connector w-3 h-3 bg-gray-500 rounded-full cursor-pointer" data-node-id="${nodeId}"></div>` : ''}
                    <button class="connect-node text-gray-400 hover:text-blue-400" data-node-id="${nodeId}">
                        <i class="fas fa-link text-xs"></i>
                    </button>
                    <button class="remove-node text-gray-400 hover:text-red-400" data-node-id="${nodeId}">
                        <i class="fas fa-times text-xs"></i>
                    </button>
                    ${outputConnectors}
                </div>
            </div>
            <p class="text-xs text-gray-400 mb-3">${nodeConfig.description}</p>
            <div class="space-y-2">
                ${nodeConfig.inputs.map(input => `
                    <div class="flex items-center space-x-2">
                        <div class="w-2 h-2 bg-blue-500 rounded-full"></div>
                        <span class="text-xs">${input}</span>
                    </div>
                `).join('')}
            </div>
        `;
        nodeElement.addEventListener('click', e => {
            if (e.shiftKey) {
                if (state.selectedNodes.has(nodeId)) {
                    state.selectedNodes.delete(nodeId);
                    nodeElement.classList.remove('selected-node');
                } else {
                    state.selectedNodes.add(nodeId);
                    nodeElement.classList.add('selected-node');
                }
            } else {
                state.selectedNodes.clear();
                document.querySelectorAll('.workflow-node').forEach(n => n.classList.remove('selected-node'));
                state.selectedNodes.add(nodeId);
                nodeElement.classList.add('selected-node');
                selectWorkflowNode(nodeId, type);
            }
            state.selectedConnection = null;
            document.querySelectorAll('.connection-path').forEach(p => p.setAttribute('stroke', '#3b82f6'));
            e.stopPropagation();
        });
        makeNodeDraggable(nodeElement);
        elements.workflowCanvas.appendChild(nodeElement);
        clearPlaceholder();
        makeNodeConnectable(nodeElement);
        updateConnectionDots();
    }

    function makeNodeDraggable(element) {
        let isDragging = false;
        let startX, startY, initialX, initialY;
        element.addEventListener('mousedown', e => {
            if (e.target.closest('button') || e.target.classList.contains('input-connector') || e.target.classList.contains('output-connector')) return;
            isDragging = true;
            startX = e.clientX;
            startY = e.clientY;
            initialX = element.offsetLeft;
            initialY = element.offsetTop;
            element.style.zIndex = '1000';
            document.addEventListener('mousemove', drag);
            document.addEventListener('mouseup', stopDrag);
        });
        function drag(e) {
            if (!isDragging) return;
            e.preventDefault();
            const dx = (e.clientX - startX) / state.zoomLevel;
            const dy = (e.clientY - startY) / state.zoomLevel;
            element.style.left = `${initialX + dx}px`;
            element.style.top = `${initialY + dy}px`;
            const nodeId = element.id;
            const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
            const node = workflow.nodes.find(n => n.id === nodeId);
            node.position = { x: initialX + dx, y: initialY + dy };
            renderConnections();
        }
        function stopDrag() {
            isDragging = false;
            element.style.zIndex = 'auto';
            document.removeEventListener('mousemove', drag);
            document.removeEventListener('mouseup', stopDrag);
        }
    }

    function makeNodeConnectable(element) {
        const connectBtn = element.querySelector('.connect-node');
        connectBtn.addEventListener('click', e => {
            e.stopPropagation();
            const nodeId = connectBtn.dataset.nodeId;
            if (state.selectedNodes.size > 1) {
                const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
                const nodes = Array.from(state.selectedNodes);
                for (let i = 1; i < nodes.length; i++) {
                    const fromNode = workflow.nodes.find(n => n.id === nodes[i - 1]);
                    if (fromNode.type !== 'notification') {
                        workflow.connections.push({ from: nodes[i - 1], to: nodes[i], scenario: null });
                    }
                }
                renderConnections();
                state.selectedNodes.clear();
                document.querySelectorAll('.workflow-node').forEach(n => n.classList.remove('selected-node'));
                updateConnectionDots();
            } else if (!isConnecting) {
                isConnecting = true;
                startNodeId = nodeId;
                connectBtn.classList.add('text-blue-400');
            } else if (startNodeId !== nodeId) {
                const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
                const fromNode = workflow.nodes.find(n => n.id === startNodeId);
                if (fromNode.type !== 'notification') {
                    workflow.connections.push({ from: startNodeId, to: nodeId, scenario: null });
                }
                isConnecting = false;
                document.querySelectorAll('.connect-node').forEach(btn => btn.classList.remove('text-blue-400'));
                renderConnections();
                startNodeId = null;
                updateConnectionDots();
            } else {
                isConnecting = false;
                connectBtn.classList.remove('text-blue-400');
                startNodeId = null;
            }
        });
        element.querySelector('.remove-node').addEventListener('click', e => {
            e.stopPropagation();
            removeNode(element.id);
        });
    }

    function renderConnections() {
        elements.connectorsSvg.innerHTML = '';
        const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
        workflow.connections.forEach((conn, idx) => {
            const fromNode = document.getElementById(conn.from);
            const toNode = document.getElementById(conn.to);
            if (fromNode && toNode) {
                const fromRect = fromNode.getBoundingClientRect();
                const toRect = toNode.getBoundingClientRect();
                const canvasRect = elements.workflowCanvas.getBoundingClientRect();
                let x1 = fromRect.right - canvasRect.left;
                let y1 = fromRect.top + fromRect.height / 2 - canvasRect.top;
                const x2 = toRect.left - canvasRect.left;
                const y2 = toRect.top + toRect.height / 2 - canvasRect.top;
                if (conn.scenario !== null) {
                    const scenarioIdx = conn.scenario;
                    const outputConnector = fromNode.querySelector(`.output-connector[data-scenario="${scenarioIdx}"]`);
                    if (outputConnector) {
                        const outputRect = outputConnector.getBoundingClientRect();
                        x1 = outputRect.left - canvasRect.left + outputRect.width / 2;
                        y1 = outputRect.top - canvasRect.top + outputRect.height / 2;
                    }
                }
                const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
                path.id = `conn-${idx}`;
                path.className = 'connection-path';
                path.setAttribute('d', `M${x1 / state.zoomLevel},${y1 / state.zoomLevel} C${(x1 + 100) / state.zoomLevel},${y1 / state.zoomLevel} ${(x2 - 100) / state.zoomLevel},${y2 / state.zoomLevel} ${x2 / state.zoomLevel},${y2 / state.zoomLevel}`);
                path.setAttribute('stroke', state.selectedConnection === idx ? '#ef4444' : '#3b82f6');
                path.setAttribute('stroke-width', '2');
                path.setAttribute('fill', 'none');
                path.setAttribute('marker-end', 'url(#arrowhead)');
                path.addEventListener('click', e => {
                    e.stopPropagation();
                    state.selectedConnection = idx;
                    document.querySelectorAll('.connection-path').forEach(p => p.setAttribute('stroke', '#3b82f6'));
                    path.setAttribute('stroke', '#ef4444');
                    state.selectedNodes.clear();
                    document.querySelectorAll('.workflow-node').forEach(n => n.classList.remove('selected-node'));
                });
                elements.connectorsSvg.appendChild(path);
            }
        });
        if (!elements.connectorsSvg.querySelector('defs')) {
            const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
            defs.innerHTML = `
                <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="0" refY="3.5" orient="auto">
                    <polygon points="0 0, 10 3.5, 0 7" fill="#3b82f6"/>
                </marker>
            `;
            elements.connectorsSvg.appendChild(defs);
        }
    }

    function updateConnectionDots() {
        const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
        document.querySelectorAll('.input-connector').forEach(dot => {
            const nodeId = dot.dataset.nodeId;
            const hasInput = workflow.connections.some(c => c.to === nodeId);
            dot.classList.toggle('bg-green-500', hasInput);
            dot.classList.toggle('bg-gray-500', !hasInput);
        });
        document.querySelectorAll('.output-connector').forEach(dot => {
            const nodeId = dot.dataset.nodeId;
            const scenario = dot.dataset.scenario;
            const hasOutput = workflow.connections.some(c => c.from === nodeId && (scenario == null || c.scenario == scenario));
            dot.classList.toggle('bg-green-500', hasOutput);
            dot.classList.toggle('bg-gray-500', !hasOutput);
        });
    }

    function getNodeConfig(type) {
        return {
            trigger: {
                title: 'Trigger',
                icon: 'fas fa-play',
                color: 'text-blue-400',
                description: 'Start workflow',
                inputs: ['Event']
            },
            'create-issue': {
                title: 'Create Issue',
                icon: 'fas fa-plus-circle',
                color: 'text-blue-600',
                description: 'Create GitHub issue',
                inputs: ['Issue title', 'Labels']
            },
            'link-issue': {
                title: 'Link Issue',
                icon: 'fas fa-link',
                color: 'text-orange-400',
                description: 'Link to existing issue',
                inputs: ['Issue number']
            },
            condition: {
                title: 'Condition',
                icon: 'fas fa-question-circle',
                color: 'text-green-400',
                description: 'Add logic branch',
                inputs: ['Condition expression']
            },
            notification: {
                title: 'Notification',
                icon: 'fas fa-bell',
                color: 'text-blue-400',
                description: 'Send alerts',
                inputs: ['Channel']
            },
            batch: {
                title: 'Batch Process',
                icon: 'fas fa-layer-group',
                color: 'text-teal-400',
                description: 'Process multiple items',
                inputs: ['Item source']
            },
            'comment-sync': {
                title: 'Comment Sync',
                icon: 'fas fa-comment-dots',
                color: 'text-pink-400',
                description: 'Sync comments',
                inputs: ['Sync direction']
            }
        }[type] || { title: 'Unknown', icon: 'fas fa-question', color: 'text-gray-400', description: '', inputs: [] };
    }

    function selectWorkflowNode(nodeId, type) {
        state.selectedNode = { id: nodeId, type };
        showNodeProperties(type);
    }

    function showNodeProperties(type) {
        elements.nodePropertiesContent.innerHTML = getNodePropertiesHTML(type);
        elements.nodeProperties.classList.remove('translate-x-full');
        if (type === 'notification') {
            const notificationType = elements.nodePropertiesContent.querySelector('#notification-type');
            notificationType?.addEventListener('change', () => updateNotificationSettings(notificationType.value));
            updateNotificationSettings(notificationType.value);
        }
        if (type === 'trigger') {
            const triggerEvent = elements.nodePropertiesContent.querySelector('#trigger-event');
            const applyCondition = elements.nodePropertiesContent.querySelector('#apply-condition');
            triggerEvent?.addEventListener('change', () => updateTriggerSettings(triggerEvent.value));
            applyCondition?.addEventListener('change', () => {
                document.getElementById('condition-settings').classList.toggle('hidden', !applyCondition.checked);
            });
            updateTriggerSettings(triggerEvent.value);
        }
        if (type === 'condition') {
            const addScenarioBtn = elements.nodePropertiesContent.querySelector('#add-scenario');
            addScenarioBtn?.addEventListener('click', () => {
                const node = state.workflows.find(wf => wf.id === state.currentWorkflowId).nodes.find(n => n.id === state.selectedNode.id);
                node.properties.scenarios.push({ condition: '', output: '' });
                showNodeProperties(type);
                updateNodeElement(state.selectedNode.id);
            });
        }
        if (type === 'create-issue') {
            const addLabelBtn = elements.nodePropertiesContent.querySelector('#add-label');
            addLabelBtn?.addEventListener('click', () => {
                const labelName = prompt('Enter label name:');
                const labelColor = prompt('Enter label color (hex):', '#ffffff');
                if (labelName && labelColor) {
                    state.githubLabels.push({ name: labelName, color: labelColor });
                    showNodeProperties(type);
                }
            });
        }
    }

    function updateNodeElement(nodeId) {
        const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
        const node = workflow.nodes.find(n => n.id === nodeId);
        if (!node) return;
        const nodeElement = document.getElementById(nodeId);
        if (!nodeElement) return;
        const nodeConfig = getNodeConfig(node.type);
        let outputConnectors = '';
        if (node.type === 'condition') {
            node.properties.scenarios.forEach((_, idx) => {
                outputConnectors += `<div class="output-connector w-3 h-3 bg-gray-500 rounded-full cursor-pointer" data-node-id="${nodeId}" data-scenario="${idx}"></div>`;
            });
        } else if (node.type !== 'notification') {
            outputConnectors = `<div class="output-connector w-3 h-3 bg-gray-500 rounded-full cursor-pointer" data-node-id="${nodeId}"></div>`;
        }
        nodeElement.innerHTML = `
            <div class="flex items-center justify-between mb-2">
                <div class="flex items-center space-x-2">
                    <i class="${nodeConfig.icon} ${nodeConfig.color}"></i>
                    <span class="font-medium text-sm">${nodeConfig.title}</span>
                </div>
                <div class="flex space-x-2">
                    ${node.type !== 'trigger' ? `<div class="input-connector w-3 h-3 bg-gray-500 rounded-full cursor-pointer" data-node-id="${nodeId}"></div>` : ''}
                    <button class="connect-node text-gray-400 hover:text-blue-400" data-node-id="${nodeId}">
                        <i class="fas fa-link text-xs"></i>
                    </button>
                    <button class="remove-node text-gray-400 hover:text-red-400" data-node-id="${nodeId}">
                        <i class="fas fa-times text-xs"></i>
                    </button>
                    ${outputConnectors}
                </div>
            </div>
            <p class="text-xs text-gray-400 mb-3">${nodeConfig.description}</p>
            <div class="space-y-2">
                ${nodeConfig.inputs.map(input => `
                    <div class="flex items-center space-x-2">
                        <div class="w-2 h-2 bg-blue-500 rounded-full"></div>
                        <span class="text-xs">${input}</span>
                    </div>
                `).join('')}
            </div>
        `;
        makeNodeConnectable(nodeElement);
        updateConnectionDots();
        renderConnections();
    }

    function updateNotificationSettings(type) {
        const settingsDiv = elements.nodePropertiesContent.querySelector('#notification-settings');
        settingsDiv.innerHTML = {
            Discord: `
                <div>
                    <label class="block text-sm font-medium mb-2">Webhook URL</label>
                    <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="https://discord.com/api/webhooks/...">
                </div>
                <div class="mt-4">
                    <label class="block text-sm font-medium mb-2">Channel</label>
                    <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="#alerts">
                </div>
            `,
            Teams: `
                <div>
                    <label class="block text-sm font-medium mb-2">Webhook URL</label>
                    <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="https://outlook.office.com/webhook/...">
                </div>
                <div class="mt-4">
                    <label class="block text-sm font-medium mb-2">Team</label>
                    <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="Dev Team">
                </div>
            `,
            Slack: `
                <div>
                    <label class="block text-sm font-medium mb-2">Webhook URL</label>
                    <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="https://hooks.slack.com/services/...">
                </div>
                <div class="mt-4">
                    <label class="block text-sm font-medium mb-2">Channel</label>
                    <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="#notifications">
                </div>
            `,
            Email: `
                <div>
                    <label class="block text-sm font-medium mb-2">Recipients</label>
                    <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="team@company.com">
                </div>
                <div class="mt-4">
                    <label class="block text-sm font-medium mb-2">Subject</label>
                    <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="New Issue Alert">
                </div>
            `,
            Desktop: `
                <div>
                    <label class="block text-sm font-medium mb-2">Message Title</label>
                    <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="Issue Notification">
                </div>
                <div class="mt-4">
                    <label class="block text-sm font-medium mb-2">Message Content</label>
                    <textarea class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 h-20" placeholder="{{severity}} issue: {{message}}"></textarea>
                </div>
            `
        }[type] || '';
    }

    function updateTriggerSettings(type) {
        const settingsDiv = elements.nodePropertiesContent.querySelector('#trigger-settings');
        settingsDiv.innerHTML = type === 'Scheduled trigger' ? `
            <div>
                <label class="block text-sm font-medium mb-2">Schedule</label>
                <select id="schedule-type" class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2">
                    <option>Every hour</option>
                    <option>Every day</option>
                    <option>Every week</option>
                    <option>Custom cron</option>
                </select>
            </div>
            <div class="mt-4 hidden" id="cron-settings">
                <label class="block text-sm font-medium mb-2">Cron Expression</label>
                <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="0 0 * * *">
            </div>
        ` : '';
        if (type === 'Scheduled trigger') {
            const cronSelect = settingsDiv.querySelector('#schedule-type');
            cronSelect.addEventListener('change', () => {
                document.getElementById('cron-settings').classList.toggle('hidden', cronSelect.value !== 'Custom cron');
            });
        }
    }

    function getNodePropertiesHTML(type) {
        return {
            trigger: `
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium mb-2">Trigger Event</label>
                        <select id="trigger-event" class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2">
                            <option>SonarQube issue created</option>
                            <option>SonarQube issue updated</option>
                            <option>Manual trigger</option>
                            <option>Scheduled trigger</option>
                        </select>
                    </div>
                    <div id="trigger-settings" class="space-y-4"></div>
                    <div>
                        <label class="block text-sm font-medium mb-2">Apply Condition</label>
                        <input type="checkbox" id="apply-condition" class="rounded">
                    </div>
                    <div id="condition-settings" class="space-y-4 hidden">
                        <div>
                            <label class="block text-sm font-medium mb-2">Filter Conditions</label>
                            <textarea class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 h-20" placeholder="severity == 'CRITICAL'"></textarea>
                        </div>
                    </div>
                </div>
            `,
            'create-issue': `
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium mb-2">Issue Title Template</label>
                        <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="[{{severity}}] {{message}}" value="[{{severity}}] {{message}}">
                    </div>
                    <div class="space-y-4">
                    <label class="block text-sm font-medium mb-2">Labels</label>
                    <div id="linked-labels" class="space-y-2">
                        ${state.githubLabels.map(label => `
                            <div class="flex items-center space-x-2">
                                <span class="text-sm">${label.name}</span>
                                <div class="w-4 h-4 rounded" style="background-color: ${label.color}"></div>
                            </div>
                        `).join('')}
                    </div>
                    <button id="add-label" class="bg-green-600 hover:bg-green-700 px-3 py-1 rounded text-xs transition-colors">Add Label</button>
                </div>
                <div>
                    <label class="block text-sm font-medium mb-2">Output Data</label>
                    <textarea class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 h-20" placeholder="issue_id, issue_url"></textarea>
                </div>
            </div>
        `,
            'link-issue': `
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium mb-2">Link Strategy</label>
                    <select class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2">
                        <option>Create sub-issue</option>
                        <option>Add comment</option>
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-medium mb-2">Parent Issue</label>
                    <input class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" placeholder="Issue #123">
                </div>
                <div>
                    <label class="block text-sm font-medium mb-2">Output Data</label>
                    <textarea class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 h-20" placeholder="linked_issue_id"></textarea>
                </div>
            </div>
        `,
            condition: `
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium mb-2">Scenarios</label>
                        <div id="scenarios" class="space-y-4">
                            ${state.workflows.find(wf => wf.id === state.currentWorkflowId)?.nodes.find(n => n.id === state.selectedNode?.id)?.properties.scenarios?.map((scenario, idx) => `
                                <div class="p-4 bg-gray-700 rounded-lg">
                                    <label class="block text-xs font-medium mb-2">Scenario ${idx + 1}</label>
                                    <textarea class="w-full bg-gray-600 border border-gray-500 rounded-lg px-3 py-2 h-20 mb-2" placeholder="severity == 'CRITICAL'" data-scenario="${idx}">${scenario.condition}</textarea>
                                    <label class="block text-xs font-medium mb-2">Output Data</label>
                                    <textarea class="w-full bg-gray-600 border border-gray-500 rounded-lg px-3 py-2 h-20" placeholder="condition_result, matched_data" data-scenario="${idx}">${scenario.output}</textarea>
                                </div>
                            `).join('') || ''}
                        </div>
                        <button id="add-scenario" class="bg-green-600 hover:bg-green-700 px-3 py-1 rounded text-xs transition-colors">Add Scenario</button>
                    </div>
                </div>
            `,
            notification: `
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium mb-2">Notification Type</label>
                    <select id="notification-type" class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2">
                        <option>Discord</option>
                        <option>Teams</option>
                        <option>Slack</option>
                        <option>Email</option>
                        <option>Desktop</option>
                    </select>
                </div>
                <div id="notification-settings" class="space-y-4"></div>
                <div>
                    <label class="block text-sm font-medium mb-2">Content</label>
                    <textarea class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 h-20" placeholder="Notification message"></textarea>
                </div>
            </div>
        `,
            batch: `
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium mb-2">Batch Size</label>
                    <input type="number" class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2" value="10" min="1" max="100">
                </div>
                <div>
                    <label class="block text-sm font-medium mb-2">Output Data</label>
                    <textarea class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 h-20" placeholder="processed_items"></textarea>
                </div>
            </div>
        `,
            'comment-sync': `
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium mb-2">Sync Direction</label>
                    <select class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2">
                        <option>GitHub to Sonar</option>
                        <option>Sonar to GitHub</option>
                        <option>Both</option>
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-medium mb-2">Output Data</label>
                    <textarea class="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 h-20" placeholder="synced_comments"></textarea>
                </div>
            </div>
        `
        }[type] || '<p class="text-gray-400">No properties available.</p>';
    }

    function removeNode(nodeId) {
        const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
        workflow.nodes = workflow.nodes.filter(n => n.id !== nodeId);
        workflow.connections = workflow.connections.filter(c => c.from !== nodeId && c.to !== nodeId);
        document.getElementById(nodeId)?.remove();
        state.selectedNodes.delete(nodeId);
        if (state.selectedNode?.id === nodeId) {
            elements.nodeProperties.classList.add('translate-x-full');
            state.selectedNode = null;
        }
        renderConnections();
        updateConnectionDots();
        addActivity('Removed node', 'fas fa-trash', 'text-red-400');
    }

    function clearPlaceholder() {
        const placeholder = elements.workflowCanvas.querySelector('.text-center');
        if (placeholder) placeholder.remove();
    }

    function renderWorkflow() {
        clearCanvas();
        state.zoomLevel = 1;
        state.canvasTransform = { x: 0, y: 0 };
        updateCanvasTransform();
        const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
        workflow.nodes.forEach(node => {
            createWorkflowNode(node.type, node.position.x, node.position.y);
            const nodeElement = document.getElementById(node.id);
            if (nodeElement) {
                nodeElement.style.left = `${node.position.x}px`;
                nodeElement.style.top = `${node.position.y}px`;
            }
        });
        renderConnections();
        updateConnectionDots();
    }

    function clearCanvas() {
        elements.workflowCanvas.innerHTML = '<svg id="connectors" class="absolute top-0 left-0 w-full h-full pointer-events-none"></svg>';
        elements.connectorsSvg = document.getElementById('connectors');
    }

    elements.saveWorkflow.addEventListener('click', () => {
        const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
        addActivity(`Saved workflow: ${workflow.name}`, 'fas fa-save', 'text-green-400');
        const saveBtn = elements.saveWorkflow;
        const originalText = saveBtn.innerHTML;
        saveBtn.innerHTML = '<i class="fas fa-check mr-2"></i>Saved!';
        saveBtn.classList.add('bg-green-700');
        setTimeout(() => {
            saveBtn.innerHTML = originalText;
            saveBtn.classList.remove('bg-green-700');
        }, 2000);
    });

    elements.runWorkflow.addEventListener('click', () => {
        const workflow = state.workflows.find(wf => wf.id === state.currentWorkflowId);
        addActivity(`Ran workflow: ${workflow.name}`, 'fas fa-play', 'text-blue-400');
    });

    elements.runAllWorkflows.addEventListener('click', () => {
        state.workflows.forEach(wf => {
            addActivity(`Ran workflow: ${wf.name}`, 'fas fa-play-circle', 'text-teal-400');
        });
    });

    // Settings Modal
    elements.settingsBtn.addEventListener('click', () => elements.settingsModal.classList.remove('hidden'));
    elements.closeSettings.addEventListener('click', () => elements.settingsModal.classList.add('hidden'));

    // Node Properties
    elements.closeProperties.addEventListener('click', () => {
        elements.nodeProperties.classList.add('translate-x-full');
        if (state.selectedNode) {
            document.getElementById(state.selectedNode.id)?.classList.remove('selected-node');
            state.selectedNode = null;
        }
        state.selectedNodes.clear();
        state.selectedConnection = null;
        document.querySelectorAll('.workflow-node').forEach(n => n.classList.remove('selected-node'));
        document.querySelectorAll('.connection-path').forEach(p => p.setAttribute('stroke', '#3b82f6'));
    });

    // Issues and Health Scores
    function updateIssues() {
        state.issues = state.repositories.flatMap(repo => [
            { id: `issue-${Math.random().toString(36).substr(2, 9)}`, repo: repo.github, severity: 'Critical', title: `Critical issue in ${repo.github}`, description: 'Auto-generated critical issue', status: 'open', labelColor: '#ef4444', assignee: 'user1' },
            { id: `issue-${Math.random().toString(36).substr(2, 9)}`, repo: repo.github, severity: 'Major', title: `Major issue in ${repo.github}`, description: 'Auto-generated major issue', status: 'open', labelColor: '#f59e0b', assignee: null },
            { id: `issue-${Math.random().toString(36).substr(2, 9)}`, repo: repo.github, severity: 'Minor', title: `Minor issue in ${repo.github}`, description: 'Auto-generated minor issue', status: 'closed', labelColor: '#3b82f6', assignee: 'user2' }
        ]);
        elements.activeIssues.textContent = state.issues.filter(i => i.status === 'open').length;
        elements.resolvedIssues.textContent = state.issues.filter(i => i.status === 'closed').length;
        renderIssues();
    }

    function renderIssues() {
        elements.issuesList.innerHTML = '';
        state.issues.forEach(issue => {
            const issueElement = document.createElement('div');
            issueElement.className = 'bg-gray-800 p-4 rounded-lg shadow-lg hover:shadow-xl transition-shadow';
            issueElement.innerHTML = `
            <div class="flex items-center justify-between mb-3">
                <div class="flex items-center space-x-2">
                    <div class="w-3 h-3 rounded" style="background-color: ${issue.labelColor}"></div>
                    <span class="font-medium text-sm">${issue.title}</span>
                </div>
                <span class="text-xs text-gray-400">${issue.status === 'open' ? 'Open' : 'Closed'}</span>
            </div>
            <p class="text-xs text-gray-400 mb-3 line-clamp-2">${issue.description}</p>
            <div class="flex items-center justify-between text-xs text-gray-400">
                <div class="flex items-center space-x-2">
                    <i class="fas fa-code-branch"></i>
                    <span>${issue.repo}</span>
                </div>
                <span>Severity: ${issue.severity}</span>
            </div>
            <div class="mt-2 text-xs text-gray-400">
                <span>Assignee: ${issue.assignee || 'Unassigned'}</span>
            </div>
        `;
            elements.issuesList.appendChild(issueElement);
        });
    }

    function updateHealthScores() {
        state.healthScores = state.repositories.map(repo => ({
            repo: repo.github,
            score: Math.floor(Math.random() * 100),
            issues: Math.floor(Math.random() * 20),
            coverage: Math.random() * 100
        }));
        renderHealthScores();
    }

    function renderHealthScores() {
        elements.healthScores.innerHTML = '';
        state.healthScores.forEach(score => {
            const scoreElement = document.createElement('div');
            scoreElement.className = 'bg-gray-700 p-4 rounded-lg';
            scoreElement.innerHTML = `
            <div class="flex items-center justify-between mb-2">
                <span class="font-medium text-sm">${score.repo}</span>
                <span class="text-sm font-semibold ${score.score >= 80 ? 'text-green-400' : score.score >= 50 ? 'text-yellow-400' : 'text-red-400'}">${score.score}%</span>
            </div>
            <div class="text-xs text-gray-400 space-y-1">
                <p>Issues: ${score.issues}</p>
                <p>Code Coverage: ${score.coverage.toFixed(1)}%</p>
            </div>
        `;
            elements.healthScores.appendChild(scoreElement);
        });
    }

    function addActivity(message, icon, color) {
        state.activities.unshift({ message, icon, color, time: new Date().toLocaleTimeString() });
        if (state.activities.length > 10) state.activities.pop();
        renderActivities();
    }

    function renderActivities() {
        elements.recentActivity.innerHTML = '';
        state.activities.forEach(activity => {
            const activityElement = document.createElement('div');
            activityElement.className = 'flex items-center space-x-3 p-2 rounded-lg hover:bg-gray-700 transition-colors';
            activityElement.innerHTML = `
            <i class="${activity.icon} ${activity.color}"></i>
            <div>
                <p class="text-sm">${activity.message}</p>
                <p class="text-xs text-gray-500">${activity.time}</p>
            </div>
        `;
            elements.recentActivity.appendChild(activityElement);
        });
    }

    // Initialize
    updateConnectionStatus();
    updateRepoSelects();
    renderRepoLinks();
    updateWorkflowSelect();
    updateIssues();
    updateHealthScores();
    renderActivities();
    initializeCharts();
});