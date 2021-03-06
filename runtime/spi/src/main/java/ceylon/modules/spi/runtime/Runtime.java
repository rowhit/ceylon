/*
 * Copyright 2011 Red Hat inc. and third party contributors as noted 
 * by the author tags.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package ceylon.modules.spi.runtime;

import ceylon.modules.Configuration;
import ceylon.modules.spi.Executable;

/**
 * Ceylon Modules runtime spi.
 *
 * @author <a href="mailto:ales.justin@jboss.org">Ales Justin</a>
 */
public interface Runtime extends Executable {
    /**
     * Create modular ClassLoader.
     *
     * @param name    the module name
     * @param version the module version
     * @param conf    the runtime configuration
     * @return holder classloader holder instance
     * @throws Exception for ay error
     */
    ClassLoaderHolder createClassLoader(String name, String version, Configuration conf) throws Exception;
}
