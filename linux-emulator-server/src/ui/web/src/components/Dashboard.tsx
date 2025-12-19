import React from 'react';

const Dashboard: React.FC = () => {
    const [emulatorStatus, setEmulatorStatus] = React.useState('Stopped');

    const startEmulator = () => {
        // Logic to start the emulator
        setEmulatorStatus('Running');
    };

    const stopEmulator = () => {
        // Logic to stop the emulator
        setEmulatorStatus('Stopped');
    };

    return (
        <div className="dashboard">
            <h1>Emulator Dashboard</h1>
            <div className="status">
                <h2>Status: {emulatorStatus}</h2>
            </div>
            <div className="controls">
                <button onClick={startEmulator} disabled={emulatorStatus === 'Running'}>
                    Start Emulator
                </button>
                <button onClick={stopEmulator} disabled={emulatorStatus === 'Stopped'}>
                    Stop Emulator
                </button>
            </div>
        </div>
    );
};

export default Dashboard;