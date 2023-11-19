<?php

declare(strict_types=1);

namespace App\Console;

final class Application extends \Symfony\Bundle\FrameworkBundle\Console\Application
{
    public function getLongVersion(): string
    {
        return \Symfony\Component\Console\Application::getLongVersion()
            . \sprintf(
                ' (env: <comment>%s</>, debug: <comment>%s</>)',
                $this->getKernel()->getEnvironment(),
                $this->getKernel()->isDebug() ? 'true' : 'false',
            );
    }
}
