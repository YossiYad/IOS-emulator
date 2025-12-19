import React, { useState } from 'react';

const Settings: React.FC = () => {
    const [config, setConfig] = useState({
        resolution: '1920x1080',
        memory: '2048',
        cpu: '2',
    });

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;
        setConfig((prevConfig) => ({
            ...prevConfig,
            [name]: value,
        }));
    };

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        // Logic to save settings goes here
        console.log('Settings saved:', config);
    };

    return (
        <div className="settings">
            <h2>Emulator Settings</h2>
            <form onSubmit={handleSubmit}>
                <div>
                    <label htmlFor="resolution">Resolution:</label>
                    <input
                        type="text"
                        id="resolution"
                        name="resolution"
                        value={config.resolution}
                        onChange={handleChange}
                    />
                </div>
                <div>
                    <label htmlFor="memory">Memory (MB):</label>
                    <input
                        type="number"
                        id="memory"
                        name="memory"
                        value={config.memory}
                        onChange={handleChange}
                    />
                </div>
                <div>
                    <label htmlFor="cpu">CPU Cores:</label>
                    <input
                        type="number"
                        id="cpu"
                        name="cpu"
                        value={config.cpu}
                        onChange={handleChange}
                    />
                </div>
                <button type="submit">Save Settings</button>
            </form>
        </div>
    );
};

export default Settings;