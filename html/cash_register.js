let robberyActive = false;
let progressInterval = null;
let currentProgress = 0;
let totalTime = 0;
let remainingTime = 0;

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
});

// Event listeners
function setupEventListeners() {
    document.getElementById('cancel-btn').addEventListener('click', cancelRobbery);
    
    // Listen for messages from FiveM
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        if (data.action === 'startCashRegisterRobbery') {
            startCashRegisterRobbery(data.duration, data.estimatedAmount);
        } else if (data.action === 'updateProgress') {
            updateProgress(data.progress);
        } else if (data.action === 'completeRobbery') {
            completeRobbery(data.amount);
        } else if (data.action === 'cancelRobbery') {
            cancelRobbery();
        }
    });
}

// Start cash register robbery
function startCashRegisterRobbery(duration, estimatedAmount) {
    if (robberyActive) return;
    
    robberyActive = true;
    totalTime = duration;
    remainingTime = duration;
    currentProgress = 0;
    
    // Show container
    document.getElementById('cash-register-container').classList.remove('hidden');
    
    // Update estimated amount
    document.getElementById('amount-display').textContent = `$${estimatedAmount.toFixed(2)}`;
    
    // Start progress tracking
    startProgressTracking();
    
    // Start cash emptying animations
    startCashAnimations();
    
    // Update status
    updateRobberyStatus('In Progress');
    
    if (window.Config && window.Config.Debug) {
        console.log('[CashRegister] Robbery started:', duration, 'ms, estimated:', estimatedAmount);
    }
}

// Start progress tracking
function startProgressTracking() {
    const startTime = Date.now();
    const endTime = startTime + totalTime;
    
    progressInterval = setInterval(() => {
        const currentTime = Date.now();
        const elapsed = currentTime - startTime;
        const progress = Math.min((elapsed / totalTime) * 100, 100);
        
        updateProgress(progress);
        updateTimeRemaining(endTime - currentTime);
        
        if (progress >= 100) {
            completeRobbery();
            return;
        }
    }, 100);
}

// Update progress bar
function updateProgress(progress) {
    currentProgress = progress;
    
    // Update progress bar
    const progressFill = document.getElementById('progress-fill');
    const progressText = document.getElementById('progress-text');
    
    progressFill.style.width = `${progress}%`;
    progressText.textContent = `${Math.round(progress)}%`;
    
    // Update cash stacks based on progress
    updateCashStacks(progress);
    
    // Update status based on progress
    if (progress < 25) {
        updateRobberyStatus('Preparing...');
    } else if (progress < 50) {
        updateRobberyStatus('Accessing Drawer...');
    } else if (progress < 75) {
        updateRobberyStatus('Emptying Cash...');
    } else if (progress < 100) {
        updateRobberyStatus('Finalizing...');
    } else {
        updateRobberyStatus('Complete!');
    }
}

// Update cash stacks
function updateCashStacks(progress) {
    const stacks = [
        document.getElementById('cash-stack-1'),
        document.getElementById('cash-stack-2'),
        document.getElementById('cash-stack-3'),
        document.getElementById('cash-stack-4')
    ];
    
    // Empty stacks based on progress
    if (progress > 20) {
        stacks[0].classList.add('emptying');
    }
    if (progress > 40) {
        stacks[1].classList.add('emptying');
    }
    if (progress > 60) {
        stacks[2].classList.add('emptying');
    }
    if (progress > 80) {
        stacks[3].classList.add('emptying');
    }
}

// Start cash animations
function startCashAnimations() {
    // Cash falling animation is handled by CSS
    // Additional cash effects can be added here
}

// Update time remaining
function updateTimeRemaining(time) {
    remainingTime = time;
    const seconds = Math.ceil(time / 1000);
    document.getElementById('time-remaining').textContent = `${seconds}s`;
}

// Update robbery status
function updateRobberyStatus(status) {
    document.getElementById('robbery-status').textContent = status;
}

// Complete robbery
function completeRobbery(amount = null) {
    if (!robberyActive) return;
    
    robberyActive = false;
    
    // Stop progress tracking
    if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
    }
    
    // Update final progress
    updateProgress(100);
    
    // Show brief completion message
    showCompletionMessage(amount);
    
    // Auto-close after 1 second and send success event
    setTimeout(() => {
        closeInterface();
        
        // Send completion event to FiveM
        if (window.GetParentResourceName) {
            fetch(`https://${window.GetParentResourceName()}/cashRegisterCompleted`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    success: true,
                    amount: amount
                })
            });
        }
    }, 1000);
    
    if (window.Config && window.Config.Debug) {
        console.log('[CashRegister] Robbery completed');
    }
}

// Show completion message
function showCompletionMessage(amount) {
    const container = document.getElementById('cash-register-container');
    const content = container.querySelector('.register-content');
    
    // Hide current content
    content.style.opacity = '0.3';
    
    // Create completion overlay
    const completionDiv = document.createElement('div');
    completionDiv.className = 'completion-overlay';
    completionDiv.innerHTML = `
        <div class="completion-content">
            <div class="completion-icon">💰</div>
            <h3>Robbery Successful!</h3>
            <p>You got away with the cash!</p>
            ${amount ? `<div class="amount-earned">$${amount.toFixed(2)}</div>` : ''}
        </div>
    `;
    
    container.appendChild(completionDiv);
    
    // Animate in
    setTimeout(() => {
        completionDiv.style.opacity = '1';
        completionDiv.style.transform = 'scale(1)';
    }, 100);
}

// Cancel robbery
function cancelRobbery() {
    if (!robberyActive) return;
    
    robberyActive = false;
    
    // Stop progress tracking
    if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
    }
    
    // Update status
    updateRobberyStatus('Cancelled');
    
    // Show cancellation message
    showCancellationMessage();
    
    // Auto-close after delay
    setTimeout(() => {
        closeInterface();
    }, 2000);
    
    // Send cancellation event to FiveM
    if (window.GetParentResourceName) {
        fetch(`https://${window.GetParentResourceName()}/cashRegisterCancelled`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                cancelled: true,
                progress: currentProgress
            })
        });
    }
    
    if (window.Config && window.Config.Debug) {
        console.log('[CashRegister] Robbery cancelled at', currentProgress, '%');
    }
}

// Show cancellation message
function showCancellationMessage() {
    const container = document.getElementById('cash-register-container');
    const content = container.querySelector('.register-content');
    
    // Hide current content
    content.style.opacity = '0.3';
    
    // Create cancellation overlay
    const cancellationDiv = document.createElement('div');
    cancellationDiv.className = 'cancellation-overlay';
    cancellationDiv.innerHTML = `
        <div class="cancellation-content">
            <div class="cancellation-icon">❌</div>
            <h3>Robbery Cancelled</h3>
            <p>You stopped the robbery!</p>
        </div>
    `;
    
    container.appendChild(cancellationDiv);
    
    // Animate in
    setTimeout(() => {
        cancellationDiv.style.opacity = '1';
        cancellationDiv.style.transform = 'scale(1)';
    }, 100);
}

// Close interface
function closeInterface() {
    const container = document.getElementById('cash-register-container');
    
    // Remove any overlays
    const overlays = container.querySelectorAll('.completion-overlay, .cancellation-overlay');
    overlays.forEach(overlay => overlay.remove());
    
    // Reset content opacity
    const content = container.querySelector('.register-content');
    content.style.opacity = '1';
    
    // Hide container
    container.classList.add('hidden');
    
    // Reset state
    robberyActive = false;
    currentProgress = 0;
    remainingTime = 0;
    
    // Reset cash stacks
    const stacks = document.querySelectorAll('.cash-stack');
    stacks.forEach(stack => stack.classList.remove('emptying'));
    
    // Reset progress
    const progressFill = document.getElementById('progress-fill');
    const progressText = document.getElementById('progress-text');
    progressFill.style.width = '0%';
    progressText.textContent = '0%';
    
    // Reset status
    updateRobberyStatus('Preparing...');
    updateTimeRemaining(0);
}

// Export functions for FiveM
if (typeof exports !== 'undefined') {
    exports('startCashRegisterRobbery', startCashRegisterRobbery);
    exports('updateProgress', updateProgress);
    exports('completeRobbery', completeRobbery);
    exports('cancelRobbery', cancelRobbery);
}
