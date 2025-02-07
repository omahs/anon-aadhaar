import { useState } from 'react'
import { ProveModal } from './ProveModal'
import styled from 'styled-components'
import { text } from '../util'
import { useEffect, useContext } from 'react'
import { AnonAadhaarContext } from '../hooks/useAnonAadhaar'

/**
 * LogInWithAnonAadhaar is a React component that provides a user interface
 * for logging in and logging out using the AnonAadhaarContext. It renders a
 * button that triggers a login modal when clicked, and provides methods to
 * initiate user login using the anon aadhaar zk circuit. The component utilizes
 * the authentication state and login request function from the context.
 *
 * @returns A JSX element representing the LogInWithAnonAadhaarV2 component.
 */
export const LogInWithAnonAadhaar = () => {
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false)
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const { state, startReq } = useContext(AnonAadhaarContext)

  useEffect(() => {
    if (state.status === 'logged-in') setIsModalOpen(false)
  }, [state])

  const openModal = () => {
    setIsModalOpen(true)
  }

  const closeModal = () => {
    setIsModalOpen(false)
    setErrorMessage(null)
  }

  return (
    <div>
      {(state.status === 'logged-out' || state.status === 'logging-in') && (
        <div>
          <Btn onClick={openModal}>
            {text('🌏', 'Log In with Anon Aadhaar')}
          </Btn>
          <ProveModal
            isOpen={isModalOpen}
            onClose={closeModal}
            errorMessage={errorMessage}
            setErrorMessage={setErrorMessage}
          ></ProveModal>
        </div>
      )}
      {state.status === 'logged-in' && (
        <div>
          <Btn onClick={() => startReq({ type: 'logout' })}>
            {text('🌏', 'Log Out')}
          </Btn>
        </div>
      )}
    </div>
  )
}

const Btn = styled.button`
  padding: 0.5rem 1rem;
  font-size: 1rem;
  cursor: pointer;
  color: #000000;
  font-weight: bold;
  border-radius: 1.3125rem;
  background: #fff;
  box-shadow: 0px 3px 8px 1px rgba(0, 0, 0, 0.25);
  border: none;
  min-width: 12rem;
  min-height: 3rem;
  border-radius: 0.5rem;

  &:hover {
    background: #fafafa;
  }

  &:active {
    background: #f8f8f8;
  }

  &:disabled {
    color: #a8aaaf;
    background: #e8e8e8;
    cursor: default;
  }
`
