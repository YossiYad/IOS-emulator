import React from 'react';
import Dashboard from './components/Dashboard';
import EmulatorView from './components/EmulatorView';
import Settings from './components/Settings';
import Editor from './components/Editor';
import './App.css';

const App: React.FC = () => {
    return (
        <div className="app-container">
            <header className="app-header">
                <h1>Linux Emulator Server</h1>
            </header>
            <main>
                <Dashboard />
                <EmulatorView />
                <Editor />
                <Settings />
            </main>
            <footer className="app-footer">
                <p>&copy; {new Date().getFullYear()} Linux Emulator Project</p>
            </footer>
        </div>
    );
};

export default App;