# AI Agent 编排框架初始化脚本 (Windows)
# 用法: .\init.ps1

# 设置 UTF-8 编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# 颜色定义 (兼容旧版 PowerShell)
$Red = "$([char]0x1b)[31m"
$Green = "$([char]0x1b)[32m"
$Yellow = "$([char]0x1b)[33m"
$Blue = "$([char]0x1b)[34m"
$NC = "$([char]0x1b)[0m"  # No Color

# 框架根目录
$FrameworkDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "$Blue╔══════════════════════════════════════════════════════════════╗$NC"
Write-Host "$Blue║         AI Agent 编排框架初始化工具                          ║$NC"
Write-Host "$Blue║                                                              ║$NC"
Write-Host "$Blue║  支持: 代码开发 | 知识管理 | 内容创作                        ║$NC"
Write-Host "$Blue╚══════════════════════════════════════════════════════════════╝$NC"
Write-Host ""

# ==================== 步骤 1: 选择场景 ====================
Write-Host "$Yellow`[1/4`] 选择工作模式`:$NC"
Write-Host ""
Write-Host "  开发类（代码为中心）:"
Write-Host "    1) 团队协作开发 (dev-team)    - 多仓库、CI/CD、代码审查"
Write-Host "    2) 个人独立开发 (dev-solo)    - 单仓库、快速迭代"
Write-Host ""
Write-Host "  内容类（知识为中心）:"
Write-Host "    3) 内容生产 (content-create)  - 写作、编辑、发布"
Write-Host "    4) 知识管理 (knowledge-mgmt)  - 收集、整理、关联、检索"
Write-Host ""

$ScenarioMap = @{
    "1" = @{ Name = "dev-team"; Display = "团队协作开发" }
    "2" = @{ Name = "dev-solo"; Display = "个人独立开发" }
    "3" = @{ Name = "content-create"; Display = "内容生产" }
    "4" = @{ Name = "knowledge-mgmt"; Display = "知识管理" }
}

while ($true) {
    $choice = Read-Host "请输入选项 (1-4)"
    if ($ScenarioMap.ContainsKey($choice)) {
        $Scenario = $ScenarioMap[$choice].Name
        $ScenarioName = $ScenarioMap[$choice].Display
        break
    } else {
        Write-Host "$Red无效选项，请重新输入$NC"
    }
}

Write-Host "  → 已选择: $Green$ScenarioName$NC"
Write-Host ""

# ==================== 步骤 2: 选择语言 ====================
Write-Host "$Yellow[2/4] 选择工作语言:$NC"
Write-Host ""
Write-Host "  1) 中文"
Write-Host "  2) English"
Write-Host ""

while ($true) {
    $langChoice = Read-Host "请输入选项 (1-2)"
    switch ($langChoice) {
        "1" { $Lang = "zh"; $LangName = "中文"; break }
        "2" { $Lang = "en"; $LangName = "English"; break }
        default { Write-Host "$Red无效选项，请重新输入$NC"; continue }
    }
    break
}

Write-Host "  → 已选择: $Green$LangName$NC"
Write-Host ""

# ==================== 步骤 3: 配置仓库 (仅工程类场景) ====================
$EngineeringScenarios = @("dev-team", "dev-solo")
$RepoMode = "none"
$RepoName = "无"

if ($EngineeringScenarios -contains $Scenario) {
    Write-Host "$Yellow[3/4] 配置仓库结构:$NC"
    Write-Host ""
    Write-Host "  1) 单仓库 - 所有代码在一个仓库中"
    Write-Host "  2) 多仓库 - 多个独立仓库（适合团队/复杂项目）"
    Write-Host ""

    while ($true) {
        $repoChoice = Read-Host "请输入选项 (1-2)"
        switch ($repoChoice) {
            "1" { $RepoMode = "single"; $RepoName = "单仓库"; break }
            "2" { $RepoMode = "multi"; $RepoName = "多仓库"; break }
            default { Write-Host "$Red无效选项，请重新输入$NC"; continue }
        }
        break
    }

    Write-Host "  → 已选择: $Green$RepoName$NC"
    Write-Host ""
} else {
    Write-Host "$Yellow[3/4] 仓库配置:$NC"
    Write-Host "  → 当前场景无需代码仓库"
    Write-Host ""
}

# ==================== 步骤 4: 确认配置 ====================
Write-Host "$Yellow[4/4] 确认配置:$NC"
Write-Host ""
Write-Host "  场景: $ScenarioName"
Write-Host "  语言: $LangName"
Write-Host "  仓库: $RepoName"
Write-Host ""

$confirm = Read-Host "确认初始化? (y/n)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "$Yellow已取消初始化$NC"
    exit 0
}

Write-Host ""
Write-Host "$Blue开始初始化...$NC"
Write-Host ""

# ==================== 执行初始化 ====================

# 1. 复制场景模板
Write-Host "  → 复制场景模板: $Scenario"
$templatePath = Join-Path $FrameworkDir "templates\$Scenario\RESOURCE-MAP.yml"
$targetPath = Join-Path $FrameworkDir "orchestrator\ALWAYS\RESOURCE-MAP.yml"

if (Test-Path $templatePath) {
    Copy-Item -Path $templatePath -Destination $targetPath -Force
    Write-Host "    $Green✓$NC 已应用 $Scenario 资源映射"
} else {
    Write-Host "    $Yellow⚠$NC 场景模板不存在，使用默认配置"
}

# 2. 更新 AGENTS.md 语言设置
Write-Host "  → 配置工作语言: $LangName"
$agentsPath = Join-Path $FrameworkDir "AGENTS.md"
if (Test-Path $agentsPath) {
    $content = Get-Content $agentsPath -Raw
    if ($Lang -eq "zh") {
        $content = $content -replace "工作语言与风格[\s\S]*?(?=---)", "工作语言与风格`n`n- 中文`n`n---`n"
    } else {
        $content = $content -replace "工作语言与风格[\s\S]*?(?=---)", "工作语言与风格`n`n- English`n`n---`n"
    }
    Set-Content -Path $agentsPath -Value $content
    Write-Host "    $Green✓$NC 已更新 AGENTS.md"
}

# 3. 创建用户工作目录
Write-Host "  → 创建工作目录"
$dirs = @(
    "outputs\code\repos",
    "outputs\documents",
    "outputs\data",
    "outputs\PROGRAMS",
    "inputs\products",
    "inputs\references"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $FrameworkDir $dir
    if (!(Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}
Write-Host "    $Green✓$NC 已创建工作目录"

# 4. 根据仓库模式创建结构 (仅工程类场景的多仓库模式)
if ($EngineeringScenarios -contains $Scenario -and $RepoMode -eq "multi") {
    Write-Host ""
    Write-Host "$Yellow[多仓库配置]$NC"
    Write-Host ""
    
    $repos = @()
    $reposDir = Join-Path $FrameworkDir "outputs\code\repos"
    
    # 先扫描已有仓库
    if (Test-Path $reposDir) {
        $existingRepos = Get-ChildItem -Path $reposDir -Directory | Where-Object { $_.Name -ne ".git" }
        if ($existingRepos.Count -gt 0) {
            Write-Host "检测到已有仓库:"
            foreach ($dir in $existingRepos) {
                Write-Host "  - $($dir.Name)"
                $repos += @{
                    Name = $dir.Name
                    Desc = $dir.Name
                    Lang = "Unknown"
                    Git = ""
                    Existing = $true
                }
            }
            Write-Host ""
            $useExisting = Read-Host "是否使用这些已有仓库? (y/n)"
            if ($useExisting -eq "y" -or $useExisting -eq "Y") {
                # 询问每个仓库的详情
                for ($i = 0; $i -lt $repos.Count; $i++) {
                    $repo = $repos[$i]
                    Write-Host ""
                    Write-Host "--- 配置: $($repo.Name) ---"
                    
                    $desc = Read-Host "描述 (默认: $($repo.Name))"
                    if (-not [string]::IsNullOrWhiteSpace($desc)) {
                        $repos[$i].Desc = $desc
                    }
                    
                    Write-Host "技术栈:"
                    Write-Host "  1) TypeScript  2) JavaScript  3) Python"
                    Write-Host "  4) Go          5) Java        6) Rust"
                    Write-Host "  7) 其他"
                    $langChoice = Read-Host "请选择 (1-7, 默认: 7)"
                    switch ($langChoice) {
                        "1" { $repos[$i].Lang = "TypeScript" }
                        "2" { $repos[$i].Lang = "JavaScript" }
                        "3" { $repos[$i].Lang = "Python" }
                        "4" { $repos[$i].Lang = "Go" }
                        "5" { $repos[$i].Lang = "Java" }
                        "6" { $repos[$i].Lang = "Rust" }
                    }
                    
                    $git = Read-Host "Git 地址 (可选)"
                    if (-not [string]::IsNullOrWhiteSpace($git)) {
                        $repos[$i].Git = $git
                    }
                }
            } else {
                $repos = @()
            }
        }
    }
    
    # 如果没有已有仓库或用户选择不使用，进入交互式创建
    if ($repos.Count -eq 0) {
        Write-Host ""
        Write-Host "进入交互式仓库创建..."
        Write-Host ""
        
        $repoIndex = 1
        while ($true) {
            Write-Host "--- 仓库 $repoIndex ---"
            $repoName = Read-Host "仓库名称 (如: backend, api-gateway)"
            
            if ([string]::IsNullOrWhiteSpace($repoName)) {
                if ($repoIndex -eq 1) {
                    Write-Host "$Red至少需要配置一个仓库$NC"
                    continue
                } else {
                    break
                }
            }
            
            if ($repoName -notmatch '^[a-z0-9-]+$') {
                Write-Host "$Red仓库名称只能包含小写字母、数字和连字符$NC"
                continue
            }
            
            $repoDesc = Read-Host "描述 (可选)"
            if ([string]::IsNullOrWhiteSpace($repoDesc)) {
                $repoDesc = $repoName
            }
            
            Write-Host "技术栈:"
            Write-Host "  1) TypeScript  2) JavaScript  3) Python"
            Write-Host "  4) Go          5) Java        6) Rust"
            Write-Host "  7) 其他"
            $langChoice = Read-Host "请选择 (1-7)"
            switch ($langChoice) {
                "1" { $repoLang = "TypeScript" }
                "2" { $repoLang = "JavaScript" }
                "3" { $repoLang = "Python" }
                "4" { $repoLang = "Go" }
                "5" { $repoLang = "Java" }
                "6" { $repoLang = "Rust" }
                default { $repoLang = "Unknown" }
            }
            
            $repoGit = Read-Host "Git 地址 (可选)"
            
            $repos += @{
                Name = $repoName
                Desc = $repoDesc
                Lang = $repoLang
                Git = $repoGit
                Existing = $false
            }
            
            # 创建仓库目录
            $repoPath = Join-Path $reposDir $repoName
            New-Item -ItemType Directory -Path $repoPath -Force | Out-Null
            Write-Host "    $Green✓$NC 已创建: $repoName"
            Write-Host ""
            
            $continue = Read-Host "继续添加? (y/n)"
            if ($continue -ne "y" -and $continue -ne "Y") {
                break
            }
            $repoIndex++
        }
    }
    
    # 生成 RESOURCE-MAP.yml
    if ($repos.Count -gt 0) {
        Write-Host ""
        Write-Host "  → 更新 RESOURCE-MAP.yml"
        
        $repoYaml = "`nrepos:`n"
        foreach ($repo in $repos) {
            $repoYaml += "  $($repo.Name):`n"
            $repoYaml += "    path: outputs/code/repos/$($repo.Name)`n"
            if (-not [string]::IsNullOrWhiteSpace($repo.Git)) {
                $repoYaml += "    git: $($repo.Git)`n"
            }
            $repoYaml += "    desc: $($repo.Desc)`n"
            $repoYaml += "    lang: $($repo.Lang)`n"
            $repoYaml += "    status: active`n"
        }
        
        $resourceMapPath = Join-Path $FrameworkDir "orchestrator\ALWAYS\RESOURCE-MAP.yml"
        if (Test-Path $resourceMapPath) {
            $existingContent = Get-Content $resourceMapPath -Raw
            $existingContent = $existingContent -replace "# ==================== 仓库列表 ====================[\s\S]*?(?=# ==================== 基础设施 ====================)", "# ==================== 仓库列表 ====================$repoYaml`n"
            Set-Content -Path $resourceMapPath -Value $existingContent
            Write-Host "    $Green✓$NC 已更新配置"
        }
        
        Write-Host ""
        Write-Host "已配置 $($repos.Count) 个仓库:"
        foreach ($repo in $repos) {
            $status = if ($repo.Existing) { "[已有]" } else { "[新建]" }
            Write-Host "  - $($repo.Name) $status ($($repo.Lang)): $($repo.Desc)"
        }
    }
}

# ==================== 完成 ====================
Write-Host ""
Write-Host "$Green╔══════════════════════════════════════════════════════════════╗$NC"
Write-Host "$Green║                   初始化完成!                                ║$NC"
Write-Host "$Green╚══════════════════════════════════════════════════════════════╝$NC"
Write-Host ""
Write-Host "  场景: $ScenarioName"
Write-Host "  语言: $LangName"
Write-Host "  仓库: $RepoName"
Write-Host ""
Write-Host "$Blue下一步`:$NC"
Write-Host ""
Write-Host "  1. 查看 README.md 了解框架详情"
Write-Host "  2. 编辑 orchestrator\ALWAYS\RESOURCE-MAP.yml 配置你的资源"
Write-Host "  3. 创建新 Program:"
Write-Host "     Copy-Item -Recurse orchestrator\PROGRAMS\_TEMPLATE\P-YYYY-NNN-name outputs\PROGRAMS\P-2026-001-my-task"
Write-Host ""
Write-Host "  4. 开始使用:"
Write-Host "     - 新 Program: xxx"
Write-Host "     - 继续 P-2026-001"
Write-Host ""
