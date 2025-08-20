let currentGame = null;
let gameTimer = null;
let timeLeft = 30;
let gameActive = false;

// Game state variables
let lockpickGame = {
    pinAngle: 0,
    targetAngle: 0,
    pinSpeed: 2,
    attempts: 3,
    score: 0,
    requiredScore: 100
};

let hackingGame = {
    grid: [],
    startNode: null,
    endNode: null,
    connectedNodes: [],
    totalNodes: 0,
    startTime: 0
};

let patternGame = {
    sequence: [],
    playerSequence: [],
    level: 1,
    score: 0,
    showingSequence: false
};

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
});

// Event listeners
function setupEventListeners() {
    // Listen for messages from FiveM
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        if (data.action === 'startMinigame') {
            startMinigame(data.type, data.difficulty, data.timeLimit, data.attempts);
        }
    });
}

// Start minigame
function startMinigame(type, difficulty, timeLimit, attempts) {
    currentGame = type;
    timeLeft = timeLimit;
    gameActive = true;
    
    // Reset game states
    resetGameStates();
    
    // Show appropriate game
    showGame(type);
    
    // Start timer
    startTimer();
    
    // Initialize specific game
    switch(type) {
        case 'lockpick':
            initLockpickGame(difficulty);
            break;
        case 'hacking':
            initHackingGame(difficulty);
            break;
        case 'pattern':
            initPatternGame(difficulty);
            break;
    }
    
    // Show container
    document.getElementById('minigame-container').classList.remove('hidden');
}

// Show specific game type
function showGame(type) {
    // Hide all games
    document.querySelectorAll('.game-type').forEach(game => {
        game.classList.add('hidden');
    });
    
    // Show selected game
    document.getElementById(type + '-game').classList.remove('hidden');
}

// Reset all game states
function resetGameStates() {
    lockpickGame = {
        pinAngle: 0,
        targetAngle: 0,
        pinSpeed: 2,
        attempts: 3,
        score: 0,
        requiredScore: 100
    };
    
    hackingGame = {
        grid: [],
        startNode: null,
        endNode: null,
        connectedNodes: [],
        totalNodes: 0,
        startTime: 0
    };
    
    patternGame = {
        sequence: [],
        playerSequence: [],
        level: 1,
        score: 0,
        showingSequence: false
    };
}

// Timer functions
function startTimer() {
    gameTimer = setInterval(() => {
        timeLeft--;
        
        if (timeLeft <= 0) {
            gameOver(false);
        }
    }, 1000);
}

function stopTimer() {
    if (gameTimer) {
        clearInterval(gameTimer);
        gameTimer = null;
    }
}

// Lockpick Game
function initLockpickGame(difficulty) {
    // Set difficulty
    switch(difficulty) {
        case 'easy':
            lockpickGame.pinSpeed = 1.5;
            lockpickGame.requiredScore = 80;
            break;
        case 'medium':
            lockpickGame.pinSpeed = 2;
            lockpickGame.requiredScore = 100;
            break;
        case 'hard':
            lockpickGame.pinSpeed = 2.5;
            lockpickGame.requiredScore = 120;
            break;
    }
    
    // Set random target angle
    lockpickGame.targetAngle = Math.random() * 360;
    
    // Start pin rotation
    rotatePin();
    
    // Add click event
    document.querySelector('.lockpick-circle').addEventListener('click', handleLockpickClick);
}

function rotatePin() {
    if (!gameActive) return;
    
    lockpickGame.pinAngle += lockpickGame.pinSpeed;
    if (lockpickGame.pinAngle >= 360) lockpickGame.pinAngle = 0;
    
    const pin = document.getElementById('lockpick-pin');
    const target = document.getElementById('lockpick-target');
    
    // Update pin position
    const pinX = Math.cos((lockpickGame.pinAngle - 90) * Math.PI / 180) * 70;
    const pinY = Math.sin((lockpickGame.pinAngle - 90) * Math.PI / 180) * 70;
    pin.style.transform = `translate(calc(-50% + ${pinX}px), calc(-50% + ${pinY}px))`;
    
    // Update target position
    const targetX = Math.cos((lockpickGame.targetAngle - 90) * Math.PI / 180) * 70;
    const targetY = Math.sin((lockpickGame.targetAngle - 90) * Math.PI / 180) * 70;
    target.style.transform = `translate(calc(-50% + ${targetX}px), calc(-50% + ${targetY}px))`;
    
    requestAnimationFrame(rotatePin);
}

function handleLockpickClick() {
    if (!gameActive) return;
    
    const angleDiff = Math.abs(lockpickGame.pinAngle - lockpickGame.targetAngle);
    const score = Math.max(0, 100 - Math.floor(angleDiff / 2));
    
    lockpickGame.score += score;
    lockpickGame.attempts--;
    
    if (lockpickGame.score >= lockpickGame.requiredScore) {
        gameOver(true);
    } else if (lockpickGame.attempts <= 0) {
        gameOver(false);
    } else {
        // New target
        lockpickGame.targetAngle = Math.random() * 360;
    }
}

// Stats update removed - elements no longer exist

// Hacking Game
function initHackingGame(difficulty) {
    const gridSize = difficulty === 'easy' ? 4 : difficulty === 'medium' ? 5 : 6;
    const nodeCount = difficulty === 'easy' ? 8 : difficulty === 'medium' ? 12 : 16;
    
    createHackingGrid(gridSize, nodeCount);
    hackingGame.startTime = Date.now();
}

function createHackingGrid(size, nodeCount) {
    const grid = document.getElementById('hacking-grid');
    grid.innerHTML = '';
    grid.style.gridTemplateColumns = `repeat(${size}, 1fr)`;
    
    const totalCells = size * size;
    const nodes = [];
    
    // Create start and end nodes
    const startIndex = Math.floor(Math.random() * totalCells);
    const endIndex = (startIndex + Math.floor(totalCells / 2)) % totalCells;
    
    // Create random nodes
    for (let i = 0; i < nodeCount - 2; i++) {
        let index;
        do {
            index = Math.floor(Math.random() * totalCells);
        } while (index === startIndex || index === endIndex || nodes.includes(index));
        nodes.push(index);
    }
    
    // Create grid
    for (let i = 0; i < totalCells; i++) {
        const cell = document.createElement('div');
        cell.className = 'hacking-node';
        
        if (i === startIndex) {
            cell.classList.add('start');
            cell.innerHTML = '<i class="fas fa-play"></i>';
            hackingGame.startNode = i;
        } else if (i === endIndex) {
            cell.classList.add('end');
            cell.innerHTML = '<i class="fas fa-flag-checkered"></i>';
            hackingGame.endNode = i;
        } else if (nodes.includes(i)) {
            cell.innerHTML = '<i class="fas fa-circle"></i>';
            hackingGame.totalNodes++;
        }
        
        cell.addEventListener('click', () => handleHackingClick(i, cell));
        grid.appendChild(cell);
    }
}

function handleHackingClick(index, cell) {
    if (!gameActive || hackingGame.connectedNodes.includes(index)) return;
    
    if (index === hackingGame.startNode) {
        hackingGame.connectedNodes = [index];
        cell.classList.add('connected');
    } else if (hackingGame.connectedNodes.length > 0) {
        // Check if adjacent to last connected node
        const lastNode = hackingGame.connectedNodes[hackingGame.connectedNodes.length - 1];
        const gridSize = Math.sqrt(document.querySelectorAll('.hacking-node').length);
        
        if (isAdjacent(lastNode, index, gridSize)) {
            hackingGame.connectedNodes.push(index);
            cell.classList.add('connected');
            
            if (index === hackingGame.endNode) {
                gameOver(true);
                return;
            }
        }
    }
}

function isAdjacent(node1, node2, gridSize) {
    const row1 = Math.floor(node1 / gridSize);
    const col1 = node1 % gridSize;
    const row2 = Math.floor(node2 / gridSize);
    const col2 = node2 % gridSize;
    
    return Math.abs(row1 - row2) <= 1 && Math.abs(col1 - col2) <= 1;
}

// Stats update removed - elements no longer exist

// Pattern Game
function initPatternGame(difficulty) {
    const sequenceLength = difficulty === 'easy' ? 3 : difficulty === 'medium' ? 4 : 5;
    
    // Generate random sequence
    for (let i = 0; i < sequenceLength; i++) {
        patternGame.sequence.push(Math.floor(Math.random() * 9));
    }
    
    createPatternGrid();
    showPatternSequence();
}

function createPatternGrid() {
    const container = document.getElementById('pattern-sequence');
    container.innerHTML = '';
    
    for (let i = 0; i < 9; i++) {
        const tile = document.createElement('div');
        tile.className = 'pattern-tile';
        tile.innerHTML = i + 1;
        tile.addEventListener('click', () => handlePatternClick(i));
        container.appendChild(tile);
    }
}

function showPatternSequence() {
    patternGame.showingSequence = true;
    patternGame.playerSequence = [];
    
    let index = 0;
    const interval = setInterval(() => {
        if (index >= patternGame.sequence.length) {
            clearInterval(interval);
            patternGame.showingSequence = false;
            return;
        }
        
        const tile = document.querySelectorAll('.pattern-tile')[patternGame.sequence[index]];
        tile.classList.add('sequence');
        
        setTimeout(() => {
            tile.classList.remove('sequence');
        }, 500);
        
        index++;
    }, 1000);
}

function handlePatternClick(index) {
    if (!gameActive || patternGame.showingSequence) return;
    
    patternGame.playerSequence.push(index);
    
    // Check if correct
    const currentIndex = patternGame.playerSequence.length - 1;
    if (patternGame.playerSequence[currentIndex] !== patternGame.sequence[currentIndex]) {
        gameOver(false);
        return;
    }
    
    // Show feedback
    const tile = document.querySelectorAll('.pattern-tile')[index];
    tile.classList.add('active');
    setTimeout(() => tile.classList.remove('active'), 300);
    
    // Check if sequence complete
    if (patternGame.playerSequence.length === patternGame.sequence.length) {
        patternGame.level++;
        patternGame.score += patternGame.sequence.length * 10;
        
        if (patternGame.level > 3) {
            gameOver(true);
        } else {
            // Next level
            patternGame.sequence.push(Math.floor(Math.random() * 9));
            setTimeout(showPatternSequence, 1000);
        }
    }
}

// Stats update removed - elements no longer exist

// Game over
function gameOver(success) {
    gameActive = false;
    stopTimer();
    
    if (success) {
        // Show success message first
        showSuccessMessage();
    }
    // Note: Retry functionality removed - game ends on failure
}

// Show success message
function showSuccessMessage() {
    const container = document.getElementById('minigame-container');
    const content = container.querySelector('.minigame-content');
    
    // Hide current game
    document.querySelectorAll('.game-type').forEach(game => {
        game.classList.add('hidden');
    });
    
    // Create success message
    const successDiv = document.createElement('div');
    successDiv.id = 'success-message';
    successDiv.className = 'success-container';
    successDiv.innerHTML = `
        <div class="success-icon">🎉</div>
        <h2 class="success-title">Success!</h2>
        <p class="success-description">You've successfully completed the minigame!</p>
        <div class="success-stats">
            <span>Game: <span class="highlight">${currentGame}</span></span>
            <span>Difficulty: <span class="highlight">${Config.Minigame.Difficulty || 'medium'}</span></span>
        </div>
        <button class="btn btn-success" onclick="closeSuccessMessage()">
            <i class="fas fa-check"></i> Continue
        </button>
    `;
    
    // Show success message
    content.appendChild(successDiv);
    
    // Auto-close after 3 seconds
    setTimeout(() => {
        if (successDiv.parentNode) {
            closeSuccessMessage();
        }
    }, 3000);
}

// Close success message
function closeSuccessMessage() {
    const successDiv = document.getElementById('success-message');
    if (successDiv) {
        successDiv.remove();
        
        // Send completion event to FiveM
        fetch(`https://${GetParentResourceName()}/minigameComplete`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                success: true
            })
        });
        
        // Hide container
        document.getElementById('minigame-container').classList.add('hidden');
    }
}

// Retry functionality removed - game ends on failure

// Close minigame functionality removed - no close button

// Utility function to get resource name
function GetParentResourceName() {
    return window.location.hostname;
}
