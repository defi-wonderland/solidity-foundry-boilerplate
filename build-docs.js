const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const tempFolder = 'technical-docs';
const baseFolder = `docs`;

const basePath = `${baseFolder}/src`;
const tempPath = `${tempFolder}/src`;

// Function to generate docs in a temporary directory
const generateDocs = () => {
  execSync(`FOUNDRY_PROFILE=docs forge doc --out "${tempFolder}"`);
};

// Function to edit generated summary not to have container pages
const editSummaryContainerPages = () => {
  // TODO: Implement this part to edit generated summary
};

// Function to edit generated summary titles to start with an uppercase letter
const editSummaryTitles = () => {
  // TODO: Implement this part to edit generated summary titles
};

// Function to edit the SUMMARY after the Interfaces section
const editSummaryAfterInterfaces = () => {
  const osType = process.platform;
  const summaryFilePath = `${basePath}/SUMMARY.md`;
  const tempSummaryFilePath = `${tempPath}/SUMMARY.md`;

  const interfacesSectionEndPattern = '\\Technical Documentation';

  mkdir(`${basePath}`);
  execSync(`touch ${summaryFilePath}`);

  const sedCommand = osType.startsWith('darwin')
    ? `sed -i '' -e '/${interfacesSectionEndPattern}/q' ${summaryFilePath}`
    : `sed -i -e '/${interfacesSectionEndPattern}/q' ${summaryFilePath}`;

  execSync(sedCommand);

  const summaryContent = fs.readFileSync(tempSummaryFilePath, 'utf8');
  const updatedContent = fs.readFileSync(tempSummaryFilePath, 'utf8').split('\n').slice(4).join('\n');
  const editedSummaryContent =
    fs.readFileSync(summaryFilePath, 'utf8').split(interfacesSectionEndPattern)[0] + updatedContent;
  fs.writeFileSync(summaryFilePath, editedSummaryContent);
};

// Function to delete old generated interfaces docs
const deleteOldGeneratedDocs = () => {
  fs.rmSync(`${basePath}`, { recursive: true });
};

// Function to move new generated interfaces docs from tmp to original directory
const moveNewGeneratedDocs = () => {
  mkdir(`${basePath}`);
  fs.cpSync(`${tempPath}`, `${basePath}`, { recursive: true });
};

// Function to delete tmp directory
const deleteTempDirectory = () => {
  fs.rmSync(tempFolder, { recursive: true });
};

// Function to replace text in all files (to fix the internal paths)
const replaceText = (dir) => {
  fs.readdirSync(dir).forEach((file) => {
    const filePath = path.join(dir, file);
    if (fs.statSync(filePath).isFile()) {
      let content = fs.readFileSync(filePath, 'utf8');
      content = content.replace(new RegExp(`${tempPath}/`, 'g'), '');
      fs.writeFileSync(filePath, content);
    } else if (fs.statSync(filePath).isDirectory()) {
      replaceText(filePath);
    }
  });
};

// Function to create directory if it does not exist
const mkdir = (dir) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

// Main function to execute all tasks
const main = () => {
  generateDocs();
  editSummaryContainerPages();
  editSummaryTitles();
  editSummaryAfterInterfaces();
  deleteOldGeneratedDocs();
  moveNewGeneratedDocs();
  deleteTempDirectory();
  replaceText(baseFolder);
};

main();
